class ContractTemplate < ActiveRecord::Base
  # belongs_to :sub_company

  mount_uploader :contract, ContractTemplateUploader
end
