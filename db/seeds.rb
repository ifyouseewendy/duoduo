# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

[EngineeringCorporation, NormalCorporation].each(&:delete_all)

[
  {
    id: 1,
    nest_id: 1,
    name: "工程合作单位1",
    start_date: "2015-08-01",
    project_date: "2015-08-10",
    project_name: "工程 xx",
    project_amount: "100.0",
    admin_amount: "50.0",
    total_amount: "150.0",
    income_date: "2015-08-11",
    income_amount: "150.0",
    outcome_date: "2015-08-12",
    outcome_referee: "用户1",
    outcome_amount: "150.0",
    proof: "",
    actual_project_amount: "200.0",
    actual_admin_amount: "100.0",
    already_get_contract: true,
    already_sign_dispatch: false,
    remark: "备注",
    jiyi_company_name: "吉易人力资源",
    created_at: "2015-08-12T02:06:11.007Z",
    updated_at: "2015-08-12T02:06:11.007Z"
  },
  {
    id: 2,
    nest_id: 2,
    name: "工程合作单位2",
    start_date: "2015-08-01",
    project_date: "2015-08-02",
    project_name: "工程 xx",
    project_amount: "100.0",
    admin_amount: "50.0",
    total_amount: "150.0",
    income_date: "2015-08-04",
    income_amount: "150.0",
    outcome_date: "2015-08-13",
    outcome_referee: "用户1",
    outcome_amount: "150.0",
    proof: "",
    actual_project_amount: "200.0",
    actual_admin_amount: "100.0",
    already_get_contract: true,
    already_sign_dispatch: false,
    remark: "",
    jiyi_company_name: "吉易人力资源",
    created_at: "2015-08-12T02:11:01.781Z",
    updated_at: "2015-08-12T02:11:01.781Z"
  }
].each{|ha| EngineeringCorporation.create(ha) }

[
  {
    id: 1,
    name: "普通合作单位1",
    license: "0124578342",
    taxpayer_serial: "2110223948",
    organization_serial: "866732",
    corporate_name: "用户1",
    address: "吉林省四平市xx街xx号",
    account: "4392223403856391",
    account_bank: "农业银行",
    contact: "用户2",
    telephone: "0434-3221322",
    contract_due_time: "2015-08-26",
    contract_amount: "100000.0",
    admin_charge_type: 0,
    admin_charge_amount: "0.1",
    expense_date: "2015-08-12",
    stuff_count: 200,
    insurance_count: 200,
    remark: "",
    jiyi_company_name: "吉易人力资源",
    created_at: "2015-08-11T06:18:23.042Z",
    updated_at: "2015-08-11T06:18:23.042Z"
  },
  {
    id: 2,
    name: "普通合作单位2",
    license: "0124578342",
    taxpayer_serial: "2110223948",
    organization_serial: "866732",
    corporate_name: "用户1",
    address: "吉林省四平市xx街xx号",
    account: "4392223403856391",
    account_bank: "农业银行",
    contact: "用户2",
    telephone: "0434-3221322",
    contract_due_time: "2015-08-26",
    contract_amount: "200000.0",
    admin_charge_type: 1,
    admin_charge_amount: "100",
    expense_date: "2015-08-12",
    stuff_count: 400,
    insurance_count: 300,
    remark: "",
    jiyi_company_name: "吉易人力资源",
    created_at: "2015-08-10T06:18:23.042Z",
    updated_at: "2015-08-10T06:18:23.042Z"
  }
].each{|ha| NormalCorporation.create(ha) }
