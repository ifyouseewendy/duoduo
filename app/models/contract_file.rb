class ContractFile < ActiveRecord::Base
  belongs_to :sub_company
  belongs_to :engineering_corp

  mount_uploader :contract, ContractUploader

  enum role: [:custom, :template]
end
