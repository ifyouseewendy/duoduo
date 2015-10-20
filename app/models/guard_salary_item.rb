class GuardSalaryItem < ActiveRecord::Base
  belongs_to :normal_staff
  belongs_to :guard_salary_table

  def salary_deserve_total
    [
      salary_deserve,
      festival,
      dress_return
    ].map(&:to_f).sum
  end

  def total_deduct
    [
      physical_exam_deduct,
      dress_deduct,
      work_exam_deduct,
      other_deduct
    ].map(&:to_f).sum
  end

  def salary_in_fact
    salary_deserve_total - total_deduct
  end

  def total
    '?'
  end

  def balance
    '?'
  end

  def staff_attribute
  end

  def staff_account
    normal_staff.account
  end

  def staff_name
    normal_staff.name rescue ''
  end

end
