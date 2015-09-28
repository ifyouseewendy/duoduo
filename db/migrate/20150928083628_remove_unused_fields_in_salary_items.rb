class RemoveUnusedFieldsInSalaryItems < ActiveRecord::Migration
  def change
    remove_columns :salary_items, :working_hour, :working_wage, :working_overtime, :working_reward
  end
end
