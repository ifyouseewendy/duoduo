class AddTransferFundToPersonAndTransferFundToAccountToSalaryItems < ActiveRecord::Migration
  def change
    add_column :salary_items, :transfer_fund_to_person, :text
    add_column :salary_items, :transfer_fund_to_account, :text
  end
end
