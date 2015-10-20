require 'thor'
require_relative 'import'

class Seed < Thor
  desc "start", ''
  def start
    load_rails

    clean_db

    seed_admin_user
    seed_sub_companies
    seed_corporations
    seed_normal_staffs
    seed_insurance_fund
    seed_salary_tables
    seed_guard_salary_tables
    seed_non_full_day_salary_tables
  end


  desc "clean_db", 'Clean DB'
  def clean_db
    puts "==> Loading Rails"
    load_rails

    puts "==> Cleaning DB data"
    [
      LaborContract,
      SalaryItem, Invoice, SalaryTable,
      GuardSalaryItem, GuardSalaryTable,
      NonFullDaySalaryItem, NonFullDaySalaryTable,
      NormalStaff, EngineeringStaff,
      NormalCorporation, EngineeringCorporation,
      ContractFile, SubCompany,
      InsuranceFundRate, IndividualIncomeTaxBase, IndividualIncomeTax,
    ].each(&:delete_all)
  end

  private

    def seed_admin_user
      if AdminUser.where(email: 'admin').first.nil?
        au = AdminUser.new(email: 'admin', password: '123123', password_confirmation: '123123')
        au.save(validate: false)
      end
    end

    def seed_sub_companies
      puts "==> Preparing SubCompany"
      Rails.application.secrets.sub_company_names.each_with_object([]) do |name, companies|
        has_engineering_relation = (name =~ /人力/ ? true : false)
        sc = SubCompany.create(name: name, has_engineering_relation: has_engineering_relation)
        (1..2).each_with_object([]) do |idx, ar|
          if File.exist?(("tmp/#{name}.合同#{idx}.txt"))
            contract = "tmp/#{name}.合同#{idx}.txt"
            sc.contract_files.create(contract: File.open(contract) )
            sc.add_file(contract, template: true)
          end
        end

        companies << sc
      end
    end

    def seed_corporations
      puts "==> Preparing EngineeringCorporation"
      (1..7).each do |id|
        (1..5).each do |nest_id|
          number        = (id-1)*5 + nest_id
          name          = "#{id}-#{nest_id}"
          days          = number.days
          amount        = number*10

          EngineeringCorporation.create!(
            main_index:             id,
            nest_index:             nest_id,
            name:                   "工程合作单位#{name}",
            start_date:             "2015-01-01".to_date + days,
            project_date:           "2015-01-01".to_date + days,
            project_name:           "工程#{name}",
            project_amount:         100.0 + amount,
            admin_amount:           50.0 + amount,
            total_amount:           150.0 + amount,
            income_date:            "2015-01-01".to_date + days,
            income_amount:          150.0 + amount,
            outcome_date:           "2015-05-01".to_date + days,
            outcome_referee:        "用户#{number}",
            outcome_amount:         150.0 + amount,
            proof:                  "凭证#{number}",
            actual_project_amount:  200.0 + amount,
            actual_admin_amount:    100.0 + amount,
            already_get_contract:   [true, false][rand(2)],
            already_sign_dispatch:  [true, false][rand(2)],
            remark:                 "备注",
            sub_companies:          SubCompany.where(has_engineering_relation: true).sample(rand(2)+1),
            created_at:             "2015-07-01".to_date + days,
            updated_at:             "2015-07-01".to_date + days
          )

        end
      end
    end

    def seed_normal_staffs
      puts "==> Preparing NormalStaff and LaborContract"
      Import.new.invoke('staff_and_contract', [], from: 'tmp/import/staff_and_contract/吉易通讯公司.xls' )
    end

    def seed_insurance_fund
      puts "==> Preparing Individual Income Tax Table"
      IndividualIncomeTaxBase.create(base: 3500)
      IndividualIncomeTax.create(grade: 1, tax_range_start: 0,     tax_range_end: 1500,       rate: 0.03)
      IndividualIncomeTax.create(grade: 2, tax_range_start: 1500,  tax_range_end: 4500,       rate: 0.1)
      IndividualIncomeTax.create(grade: 3, tax_range_start: 4500,  tax_range_end: 9000,       rate: 0.2)
      IndividualIncomeTax.create(grade: 4, tax_range_start: 9000,  tax_range_end: 35000,      rate: 0.25)
      IndividualIncomeTax.create(grade: 5, tax_range_start: 35000, tax_range_end: 55000,      rate: 0.3)
      IndividualIncomeTax.create(grade: 6, tax_range_start: 55000, tax_range_end: 80000,      rate: 0.35)
      IndividualIncomeTax.create(grade: 7, tax_range_start: 80000, tax_range_end: 999999999,  rate: 0.45)

      puts "==> Preparing Insurance Fund Rate Table"
      InsuranceFundRate.create(name: '个人', pension: 0.08, unemployment: 0.005, medical: 0.02, injury: 0, birth: 0, house_accumulation: 96)
      InsuranceFundRate.create(name: '公司', pension: 0.2,  unemployment: 0.015, medical: 0.06, injury: 0.015, birth: 0.004, house_accumulation: 96)

    end

    def seed_salary_tables
      puts "==> Preparing SalaryTable, SalaryItem and Invoice"
      count = NormalCorporation.count*2
      (1..count).each do |id|
        puts "... Processing #{id}/#{count}" if id % 10 == 0
        nc = NormalCorporation.all.sample

        month = (1..12).to_a.sample

        st = SalaryTable.create!(
          name: "2015年#{month}月",
          normal_corporation: nc
        )

        date = "2015-01-01".to_date + id.days
        Invoice.create!(
          salary_table: st,
          release_date: date,
          encoding: 'XC10329837',
          payer: NormalStaff.all.sample.name,
          project_name: "#{nc.name} - #{st.name}",
          amount: (1..5).to_a.sample*100000,
          total_amount: (6..9).to_a.sample*100000,
          contact_person: NormalStaff.all.sample.name,
          refund_person: NormalStaff.all.sample.name,
          income_date: date,
          refund_date: date + 10.days
        )

        begin
          st.normal_corporation.normal_staffs.each do |staff|
            SalaryItem.create_by(salary_table: st, salary: (1..8).to_a.sample*1000, name: staff.name, identity_card: staff.identity_card)
          end
        rescue => e
          require'pry';binding.pry
        end
      end
    end

    def seed_guard_salary_tables
      puts "==> Preparing GuardSalaryTable, GuardSalaryItem and Invoice"
      count = NormalCorporation.count*2
      (1..count).each do |id|
        puts "... Processing #{id}/#{count}" if id % 10 == 0
        nc = NormalCorporation.all.sample

        month = (1..12).to_a.sample

        st = GuardSalaryTable.create!(
          name: "2015年#{month}月",
          normal_corporation: nc
        )

        date = "2015-01-01".to_date + id.days
        Invoice.create!(
          guard_salary_table: st,
          release_date: date,
          encoding: 'XC10329837',
          payer: NormalStaff.all.sample.name,
          project_name: "#{nc.name} - #{st.name}",
          amount: (1..5).to_a.sample*100000,
          total_amount: (6..9).to_a.sample*100000,
          contact_person: NormalStaff.all.sample.name,
          refund_person: NormalStaff.all.sample.name,
          income_date: date,
          refund_date: date + 10.days
        )

        begin
          st.normal_corporation.normal_staffs.each do |staff|
            GuardSalaryItem.create!(
              normal_staff: staff,
              guard_salary_table: st,
              income: 10000,
              salary_deserve: 10000,
              festival: 1000,
              dress_return: 1000,
              salary_deserve_total: nil,
              physical_exam_deduct: 1000,
              dress_deduct: 1000,
              work_exam_deduct: 0,
              other_deduct: 0,
              total_deduct: nil,
              salary_in_fact: nil,
              accident_insurance: 1000,
              total: nil,
              balance: nil
            )
          end
        rescue => e
          require'pry';binding.pry
        end
      end
    end

    def seed_non_full_day_salary_tables
      puts "==> Preparing NonFullDaySalaryTable, NonFullDaySalaryItem and Invoice"
      count = NormalCorporation.count*2
      (1..count).each do |id|
        puts "... Processing #{id}/#{count}" if id % 10 == 0
        nc = NormalCorporation.all.sample

        month = (1..12).to_a.sample

        st = NonFullDaySalaryTable.create!(
          name: "2015年#{month}月",
          normal_corporation: nc
        )

        date = "2015-01-01".to_date + id.days
        Invoice.create!(
          non_full_day_salary_table: st,
          release_date: date,
          encoding: 'XC10329837',
          payer: NormalStaff.all.sample.name,
          project_name: "#{nc.name} - #{st.name}",
          amount: (1..5).to_a.sample*100000,
          total_amount: (6..9).to_a.sample*100000,
          contact_person: NormalStaff.all.sample.name,
          refund_person: NormalStaff.all.sample.name,
          income_date: date,
          refund_date: date + 10.days
        )

        begin
          st.normal_corporation.normal_staffs.each do |staff|
            NonFullDaySalaryItem.create!(
              normal_staff: staff,
              non_full_day_salary_table: st,
              month: "#{(1..12).to_a.sample}月",
              work_hour: (10..30).to_a.sample,
              work_wage: (10..50).to_a.sample,
              salary_deserve: nil,
              tax: 100,
              other: 100,
              salary_in_fact: nil,
              accident_insurance: 100,
              admin_amount: nil,
              total: nil,
              remark: '备注'
            )
          end
        rescue => e
          require'pry';binding.pry
        end
      end
    end

    def load_rails
      require File.expand_path('config/environment.rb')
    end

    def rand_by(len)
      rand.to_s[2..(2+len-1)]
    end

    def random_date(base = '1980-01-01')
      Date.parse(base) + rand(10).years + rand(300).days
    end

end

Seed.start(ARGV)
