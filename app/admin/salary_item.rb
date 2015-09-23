ActiveAdmin.register SalaryItem do
  belongs_to :salary_table

  breadcrumb do
    [salary_table.corporation.name, salary_table.name]
  end
end
