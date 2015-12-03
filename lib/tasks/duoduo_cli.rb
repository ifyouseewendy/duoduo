require 'thor'

class DuoduoCli < Thor
  attr_reader :logger

  desc "hello NAME", "say hello to NAME"
  def hello(name)
    puts "Hello #{name}"
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

    def clean_db(types)
      puts "==> Cleaning DB data"

      types = Array.wrap(types)
      collection = []

      if types.include? :business
        collection += [
          LaborContract,
          SalaryItem, Invoice, SalaryTable,
          GuardSalaryItem, GuardSalaryTable,
          NonFullDaySalaryItem, NonFullDaySalaryTable,
          NormalStaff, NormalCorporation,
          ContractFile, SubCompany,
          InsuranceFundRate, IndividualIncomeTaxBase, IndividualIncomeTax,
        ]
      end

      if types.include? :engineer
        collection += [
          EngineeringSalaryTable,
          EngineeringStaff, EngineeringProject, EngineeringCorp, EngineeringCustomer,
          EngineeringCompanySocialInsuranceAmount, EngineeringCompanyMedicalInsuranceAmount
        ]
      end

      collection.each(&:destroy_all)
    end

    def init_logger
      @logger ||= ActiveSupport::Logger.new('log/import.log')
    end

    def seed_sub_companies
      puts "==> Preparing SubCompany"
      Rails.application.secrets.sub_company_names.each_with_object([]) do |name, companies|
        has_engineering_relation = (name =~ /人力/ ? true : false)
        sc = SubCompany.create!(name: name, has_engineering_relation: has_engineering_relation)
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
end


