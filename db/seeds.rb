[NormalStaff, ContractFile, EngineeringCorporation, NormalCorporation, SubCompany].each(&:delete_all)

sub_companies = Rails.application.secrets.sub_company_names.each_with_object([]) do |name, companies|
  sc = SubCompany.create(name: name)
  (1..2).each_with_object([]) do |idx, ar|
    contract = File.open("tmp/#{name}.合同#{idx}.txt") if File.exist?(("tmp/#{name}.合同#{idx}.txt"))
    sc.contract_files.create(contract: contract)
  end
end

def rand_by(len)
  rand.to_s[2..(2+len-1)]
end

puts "--> Creating NormalCorporation and EngineeringCorporation"
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

    NormalCorporation.create!(
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
      sub_companies:        sub_companies.sample(rand(6)),
      created_at:           "2015-07-01".to_date + days,
      updated_at:           "2015-07-01".to_date + days
    )

    EngineeringCorporation.create!(
      main_index:             id,
      nest_index:             nest_id,
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
      sub_companies:          sub_companies.sample(rand(6)),
      created_at:             "2015-07-01".to_date + days,
      updated_at:             "2015-07-01".to_date + days
    )

  end
end

def random_date(base = '1980-01-01')
  Date.parse(base) + rand(10).years + rand(300).days
end

puts "--> Creating NormalStaff and EngineeringStaff"
(1..7).each do |id|
  nc = NormalCorporation.offset(id).take

  (1..5).each do |nest_id|
    bank          = ['工商银行', '农业银行', '交通银行', '建设银行'].sample
    birth         = random_date
    grade         = ['本科', '大专', '研究生'].sample
    address       = "四平市#{id}街#{nest_id}号"

    staff = Jia::User.new

    NormalStaff.create!(
      normal_corporation: nc,
      nest_id: nest_id,
      name: staff.full_name,
      company_name: nc.name,
      account: rand_by(10),
      account_bank: bank,
      identity_card: rand_by(10),
      birth: birth,
      age: (Date.today - birth).to_i/365,
      gender: rand(2),
      nation: '汉族',
      grade: grade,
      address:  address,
      telephone: staff.phone,
      social_insurance_start_date: random_date('1990-01-01'),
      current_social_insurance_start_date: random_date('2000-01-01'),
      current_medical_insurance_start_date: random_date('2000-01-01'),
      social_insurance_base: 1000,
      medical_insurance_base: 800,
      has_social_insurance: [true, false].sample,
      has_medical_insurance: [true, false].sample,
      in_service: [true, false].sample,
      in_release: [true, false].sample,
      house_accumulation_base: 800,
      arrive_current_company_at: random_date('2000-01-01'),
      contract_start_date: random_date('2005-01-01'),
      contract_end_date: random_date('2010-01-01'),
      social_insurance_serial: rand_by(10),
      medical_insurance_serial: rand_by(10),
      medical_insurance_card: rand_by(10),
      backup_date: random_date('2005-01-01'),
      backup_place: '四平市',
      work_place: '四平市',
      work_type: ['人力', '物业', '财务', '保安'].sample,
      remark: '备注'
    )
  end
end
