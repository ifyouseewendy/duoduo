class AddAllIndexToEngineeringNormalWithTaxSalaryItems < ActiveRecord::Migration
  def change
    add_index :engineering_normal_with_tax_salary_items, :salary_deserve, name: 'idx_engi_si_with_tax_salary_deserve'
    add_index :engineering_normal_with_tax_salary_items, :social_insurance, name: 'idx_engi_si_with_tax_social_insurance'
    add_index :engineering_normal_with_tax_salary_items, :medical_insurance, name: 'idx_engi_si_with_tax_medical_insurance'
    add_index :engineering_normal_with_tax_salary_items, :total_insurance, name: 'idx_engi_si_with_tax_total_insurance'
    add_index :engineering_normal_with_tax_salary_items, :total_amount, name: 'idx_engi_si_with_tax_total_amount'
    add_index :engineering_normal_with_tax_salary_items, :tax
    add_index :engineering_normal_with_tax_salary_items, :salary_in_fact, name: 'idx_engi_si_with_tax_salary_in_fact'
    add_index :engineering_normal_with_tax_salary_items, :remark
  end
end
