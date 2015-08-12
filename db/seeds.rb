[EngineeringCorporation, NormalCorporation].each(&:delete_all)

def rand_by(len)
  rand.to_s[2..(2+len-1)]
end

(1..7).each do |id|
  (1..5).each do |nest_id|
    number        = (id-1)*5 + nest_id
    name          = "#{id}-#{nest_id}"
    days          = number.days
    amount        = number*10
    random_number = rand_by(10)
    charge_type   = rand(2)
    charge_amount = case charge_type
                    when 0 then rand.to_s[0..3]
                    when 1 then [100,200][rand(2)]
                    end

    NormalCorporation.create(
      id:                   number,
      name:                 "普通合作单位#{number}",
      license:              rand_by(10),
      taxpayer_serial:      rand_by(10),
      organization_serial:  rand_by(10),
      corporate_name:       "用户#{number}",
      address:              "四平市#{id}街#{nest_id}号",
      account:              random_number,
      account_bank:         "XX 银行",
      contact:              "用户#{number}",
      telephone:            "#{rand_by(4)}-#{rand_by(7)}",
      contract_due_time:    "2015-01-01".to_date + days,
      contract_amount:      1000 + amount,
      admin_charge_type:    charge_type,
      admin_charge_amount:  charge_amount,
      expense_date:         "2015-07-01".to_date + days,
      stuff_count:          rand(300),
      insurance_count:      rand(300),
      remark:               "备注",
      jiyi_company_name:    Rails.application.secrets.jiyi_company_names[rand(6)],
      created_at:           "2015-07-01".to_date + days,
      updated_at:           "2015-07-01".to_date + days
    )

    EngineeringCorporation.create(
      id:                     number,
      main_id:                id,
      nest_id:                nest_id,
      name:                   "工程合作单位#{name}",
      start_date:             "2015-01-01".to_date + days,
      project_date:           "2015-01-01".to_date + days,
      project_name:           "工程#{name}",
      project_amount:         100.0 + amount,
      admin_amount:           50.0 + amount,
      total_amount:           150.0 + amount,
      income_date:            "2015-01-01".to_date + days,
      income_amount:          150.0 + amount,
      outcome_date:           "2015-05-01".to_date + days,
      outcome_referee:        "用户#{number}",
      outcome_amount:         150.0 + amount,
      proof:                  "凭证#{number}",
      actual_project_amount:  200.0 + amount,
      actual_admin_amount:    100.0 + amount,
      already_get_contract:   [true, false][rand(2)],
      already_sign_dispatch:  [true, false][rand(2)],
      remark:                 "备注",
      jiyi_company_name:      Rails.application.secrets.jiyi_company_names[rand(6)],
      created_at:             "2015-07-01".to_date + days,
      updated_at:             "2015-07-01".to_date + days
    )
  end
end
