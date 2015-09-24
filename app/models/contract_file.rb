class ContractFile < ActiveRecord::Base
  belongs_to :sub_company

  mount_uploader :contract, ContractUploader

  enum role: [:custom, :template]
end