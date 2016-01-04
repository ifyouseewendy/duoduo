require 'thor'
require_relative 'distinct_file_logger'

class DuoduoCli < Thor
  attr_reader :logger

  LOGGER_PATH = 'log/import.csv'

  desc "hello NAME", "say hello to NAME"
  def hello(name)
    puts "Hello #{name}"
  end

  desc "base", ''
  def base
    load_rails
    clean_db(:business, :engineer, :base)

    seed_admin_user
    seed_sub_companies
    seed_insurance_fund
  end

  desc 'seed_admin_user', ''
  def seed_admin_user
    load_rails
    puts "==> Preparing AdminUser"

    AdminUser.delete_all
    au = AdminUser.new(name: 'admin', password: '123123', password_confirmation: '123123')
    au.save(validate: false)
  end

  desc 'seed_sub_companies', ''
  def seed_sub_companies
    load_rails
    puts "==> Preparing SubCompany"
    names = Rails.application.secrets.sub_company_names
    return if SubCompany.pluck(:name).to_set == names.to_set

    names.each do |name|
      has_engineering_relation = (name =~ /人力/ ? true : false)
      sc = SubCompany.where(name: name, has_engineering_relation: has_engineering_relation).first

      if has_engineering_relation
        if name == '吉易人力资源（公主岭分）'
          sc.engi_contract_template = File.open( Rails.root.join('db').join('template').join('人力分_工程合同模版.docx') )
          sc.engi_protocol_template = File.open( Rails.root.join('db').join('template').join('人力分_代发协议模板.docx') )
        elsif name == '吉易人力资源'
          sc.engi_contract_template = File.open( Rails.root.join('db').join('template').join('人力_工程合同模版.docx') )
          sc.engi_protocol_template = File.open( Rails.root.join('db').join('template').join('人力_代发协议模板.docx') )
        end
      else
        # (1..2).each_with_object([]) do |idx, ar|
        #   if File.exist?(("tmp/#{name}.合同#{idx}.txt"))
        #     contract = "tmp/#{name}.合同#{idx}.txt"
        #     sc.contract_files.create(contract: File.open(contract) )
        #     sc.add_file(contract, template: true)
        #   end
        # end
      end

      sc.save!
    end
  end

  desc 'seed_insurance_fund', ''
  def seed_insurance_fund
    load_rails
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
  private

    def load_from(from)
      fail "Invalid <from> file position: #{from}" unless File.exist?(from)
      Pathname(from)
    end

    def load_rails
      return if defined? Rails

      puts "==> Loading Rails"
      require File.expand_path('config/environment.rb')
    end

    def clean_db(*types)
      puts "==> Cleaning DB data, strategy: #{types.join(', ')}"

      collection = []

      if types.include? :business
        collection += [
          LaborContract,
          SalaryItem, Invoice, SalaryTable,
          GuardSalaryItem, GuardSalaryTable,
          NonFullDaySalaryItem, NonFullDaySalaryTable,
          NormalStaff, NormalCorporation,
        ]
      end

      if types.include? :business_staff
        collection += [
          LaborContract, NormalStaff
        ]
      end

      if types.include? :business_salary
        collection += [
          SalaryItem, Invoice, SalaryTable,
          GuardSalaryItem, GuardSalaryTable,
          NonFullDaySalaryItem, NonFullDaySalaryTable,
        ]
      end

      if types.include? :engineer
        collection += [
          EngineeringSalaryTable,
          EngineeringStaff, EngineeringProject, EngineeringCustomer,
          EngineeringCompanySocialInsuranceAmount, EngineeringCompanyMedicalInsuranceAmount
        ]
      end

      if types.include? :engineer_corp
        collection += [
          EngineeringCorp
        ]
      end

      if types.include? :base
        collection += [
          AdminUser,
          SubCompany,
          InsuranceFundRate, IndividualIncomeTaxBase, IndividualIncomeTax,
        ]
      end

      collection.uniq.each(&:destroy_all)
    end

    def init_logger
      @logger ||= DistinctFileLogger.new(LOGGER_PATH)
    end

    def clean_logger
      File.unlink(LOGGER_PATH) if File.exist?(LOGGER_PATH)
    end

end

DuoduoCli.start(ARGV)
