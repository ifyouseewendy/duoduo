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

      collection = []

      if types.include? :business
        collection << [
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
        collection << [
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

end


