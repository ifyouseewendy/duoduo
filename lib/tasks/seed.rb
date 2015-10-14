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
  end


  desc "clean_db", 'Clean DB'
  def clean_db
    puts "==> Loading Rails"
    load_rails

    puts "==> Cleaning DB data"
    [
      LaborContract,
      SalaryItem, SalaryTable,
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
      puts "==> Preparing SalaryTable and SalaryItem"
      count = NormalCorporation.count*5
      (1..count).each do |id|
        puts "... Processing #{id}/#{count}" if id % 10 == 0
        nc = NormalCorporation.all.sample

        month = (1..12).to_a.sample

        st = SalaryTable.create!(
          name: "2015年#{month}月",
          normal_corporation: nc
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
