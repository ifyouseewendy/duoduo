class SubCompany < ActiveRecord::Base
  has_and_belongs_to_many :normal_corporations
  has_and_belongs_to_many :engineering_corporations

  mount_uploaders :contracts, ContractUploader

  def add_file(filename, override: false)
    if override
      self.contracts = [File.open(filename)]
    else
      self.contracts = self.contracts + [File.open(filename)]
    end

    self.save!
  end
end
