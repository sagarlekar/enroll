puts "*"*80

puts "::: Generating Employers seed data :::"

# Retrieve Brokers
broker_agency_0 = BrokerAgencyProfile.first
broker_agency_1 = BrokerAgencyProfile.last


puts "::: Creating Jetsons :::"
address_00 = Address.new(kind: "work", address_1: "100 Cosmic Way, NW", city: "Washington", state: "DC", zip: "20001")
phone_00 = Phone.new(kind: "main", area_code: "202", number: "555-1213")
email_00 = Email.new(kind: "work", address: "info@spacely.com")
office_location_00 = OfficeLocation.new(is_primary: true, address: address_00, phone: phone_00, email: email_00)
spacely = Organization.create(
      dba: "Spacely's Sprockets",
      legal_name: "Spacely's Sprockets, Inc",
      fein: 444123456,
      office_locations: [office_location_00]
    )

address_01 = Address.new(kind: "work", address_1: "100 Milky Way, SW", city: "Washington", state: "DC", zip: "20001")
phone_01 = Phone.new(kind: "main", area_code: "202", number: "555-1214")
email_01 = Email.new(kind: "work", address: "info@spacely.com")
office_location_01 = OfficeLocation.new(is_primary: true, address: address_01, phone: phone_01, email: email_01)

address_02 = Address.new(kind: "work", address_1: "311 Venus Pkwy, NW", city: "Washington", state: "DC", zip: "20001")
phone_02 = Phone.new(kind: "main", area_code: "202", number: "555-1215")
email_02 = Email.new(kind: "work", address: "info@spacely.com")
office_location_02 = OfficeLocation.new(is_primary: false, address: address_02, phone: phone_02, email: email_02)

cogswell = Organization.create(
      dba: "Cogswell Cogs",
      legal_name: "Cogswell Cogs, Inc",
      fein: 555123457,
      office_locations: [office_location_01, office_location_02]
    )

jetson_0 = EmployerCensus::EmployeeFamily.new(
    census_employee: EmployerCensus::Employee.new(
        last_name: "Jetson", first_name: "George", dob: "04/01/1974", ssn: 987654321, hired_on: "03/20/2015",
        email: Email.new(kind: "work", address: "dan.thomas@dc.gov")
      ),
    census_dependents: [
      EmployerCensus::Dependent.new(
        last_name: "Jetson", first_name: "Jane", dob: "04/01/1981", ssn: 987654322, employee_relationship: "spouse"
        ),
      EmployerCensus::Dependent.new(
        last_name: "Jetson", first_name: "Judy", dob: "04/01/2000", ssn: 987654323, employee_relationship: "child_under_26"
        ),
      EmployerCensus::Dependent.new(
        last_name: "Jetson", first_name: "Elroy", dob: "04/01/2008", ssn: 987654324, employee_relationship: "child_under_26"
        )
    ]
  )

jetson_1 = EmployerCensus::EmployeeFamily.new(
    census_employee: EmployerCensus::Employee.new(
        last_name: "Jetson", first_name: "Jane", dob: "04/01/1981", ssn: 987654322, hired_on: "03/23/2015",
        email: Email.new(kind: "work", address: "dan.thomas@dc.gov")
      )
    )

spacely_employer_profile = spacely.create_employer_profile(
    entity_kind: "s_corporation",
    broker_agency_profile: broker_agency_0,
    employee_families: [jetson_0]
  )

spacely_plan_year = spacely_employer_profile.plan_years.build(
    start_on: 0.days.ago.beginning_of_year.to_date,
    end_on: 0.days.ago.end_of_year.to_date,
    open_enrollment_start_on: (0.days.ago.beginning_of_year.to_date - 2.months).beginning_of_month,
    open_enrollment_end_on: (0.days.ago.beginning_of_year.to_date - 2.months).end_of_month,
    fte_count: 3,
    pte_count: 2
  )

spacely_plan = Plan.create(
    active_year: 2015,
    hios_id: "123523",
    name: "BlueChoice 123 Silver 100",
    coverage_kind: "health",
    metal_level: "silver",
    market: "shop",
    carrier_profile_id: CarrierProfile.last.id
  )

spacely_benefit_group = spacely_plan_year.benefit_groups.build(
    effective_on_kind:  "date_of_hire",
    terminate_on_kind:  "end_of_month",
    effective_on_offset:  30,
    premium_pct_as_int:   80,
    employer_max_amt_in_cents:  1000_00,
    reference_plan: spacely_plan
  )

spacely_benefit_group.relationship_benefits.build(
    relationship: "employee",
    premium_pct: 60,
    employer_max_amt: 1000.00
  )
spacely.save!

cogswell_employer_profile = cogswell.create_employer_profile(
    entity_kind: "s_corporation",
    broker_agency_profile: broker_agency_1,
    employee_families: [jetson_1]
  )

cogswell_plan_year = cogswell_employer_profile.plan_years.build(
    start_on: 0.days.ago.beginning_of_year.to_date,
    end_on: 0.days.ago.end_of_year.to_date,
    open_enrollment_start_on: (0.days.ago.beginning_of_year.to_date - 2.months).beginning_of_month,
    open_enrollment_end_on: (0.days.ago.beginning_of_year.to_date - 2.months).end_of_month,
    fte_count: 30,
    pte_count: 21
  )

cogswell_plan = Plan.create(
    active_year: 2015,
    hios_id: "120523",
    name: "United 123 Silver 900",
    coverage_kind: "health",
    metal_level: "bronze",
    market: "shop",
    carrier_profile_id: CarrierProfile.first.id
  )

cogswell_benefit_group = cogswell_plan_year.benefit_groups.build(
    effective_on_kind:  "date_of_hire",
    terminate_on_kind:  "end_of_month",
    effective_on_offset:  30,
    premium_pct_as_int:   80,
    employer_max_amt_in_cents:  1000_00,
    reference_plan: cogswell_plan
  )

cogswell_benefit_group.relationship_benefits.build(
    relationship: "employee",
    premium_pct: 80,
    employer_max_amt: 500.00
  )
cogswell.save!

puts "::: Creating addresses for office location :::"
# Employer addresses
org_1_add = Address.new(kind: "work", address_1: "823 Cosmic Way, NW", city: "Washington", state: "DC", zip: "20001")
org_1_phone = Phone.new(kind: "main", area_code: "802", number: "123-1213")
org_1_email = Email.new(kind: "work", address: "info@organization1.com")
org_1_off_loc = OfficeLocation.new(is_primary: true, address: org_1_add, phone: org_1_phone, email: org_1_email)

org_1 = Organization.new(
      dba: "1234",
      legal_name: "Global Systems",
      fein: 978978971,
      office_locations: [org_1_off_loc]
    )

org_1_jetson = EmployerCensus::EmployeeFamily.new(
    census_employee: EmployerCensus::Employee.new(
        last_name: "Doe", first_name: "John", dob: "01/12/1980", ssn: "111222331", hired_on: "03/20/2015",
        email: Email.new(kind: "work", address: "john.doe@example.com")
      ),
    census_dependents: [
      EmployerCensus::Dependent.new(
        last_name: "Doe", first_name: "Matt", dob: "01/12/2011", ssn: "022233311", employee_relationship: "child_under_26"
        ),
      EmployerCensus::Dependent.new(
        last_name: "Doe", first_name: "Jessica", dob: "03/12/1985", ssn: "021233311", employee_relationship: "spouse"
        ),
      EmployerCensus::Dependent.new(
        last_name: "Doe", first_name: "Caroline", dob: "04/01/2008", ssn: "021233321", employee_relationship: "child_under_26"
        )
    ]
  )

org_1_employer = org_1.create_employer_profile(
    entity_kind: "s_corporation",
    broker_agency_profile: broker_agency_1,
    employee_families: [org_1_jetson]
  )

org_1_plan_year = org_1_employer.plan_years.build(
    start_on: 0.days.ago.beginning_of_year.to_date,
    end_on: 0.days.ago.end_of_year.to_date,
    open_enrollment_start_on: (0.days.ago.beginning_of_year.to_date - 2.months).beginning_of_month,
    open_enrollment_end_on: (0.days.ago.beginning_of_year.to_date - 2.months).end_of_month,
    fte_count: 12,
    pte_count: 1
  )

org_1_plan = Plan.create(
    active_year: 2015,
    hios_id: "191503",
    name: "UHC 123 Silver 900",
    coverage_kind: "health",
    metal_level: "silver",
    market: "shop",
    carrier_profile_id: CarrierProfile.last.id
  )

org_1_benefit_group = org_1_plan_year.benefit_groups.build(
    effective_on_kind:  "date_of_hire",
    terminate_on_kind:  "end_of_month",
    effective_on_offset:  30,
    premium_pct_as_int:   80,
    employer_max_amt_in_cents:  500_00,
    reference_plan: org_1_plan
  )

org_1_benefit_group.relationship_benefits.build(
    relationship: "employee",
    premium_pct: 85,
    employer_max_amt: 300.00
  )
org_1.save!

org_2_add = Address.new(kind: "work", address_1: "823 Cosmic Way, NW", city: "Washington", state: "DC", zip: "20001")
org_2_phone = Phone.new(kind: "main", area_code: "802", number: "123-1213")
org_2_email = Email.new(kind: "work", address: "info@organization1.com")
org_2_off_loc = OfficeLocation.new(is_primary: true, address: org_2_add, phone: org_2_phone, email: org_2_email)

org_2 = Organization.new(
      dba: "3434",
      legal_name: "Technology Solutions Inc.",
      fein: 397897897,
      office_locations: [org_2_off_loc]
    )

org_2_jetson = EmployerCensus::EmployeeFamily.new(
    census_employee: EmployerCensus::Employee.new(
        last_name: "Johnson", first_name: "Patricia", dob: "01/12/1980", ssn: "311222331", hired_on: "03/20/2015",
        email: Email.new(kind: "work", address: "patricia.johnson@example.com")
      ),
    census_dependents: [
      EmployerCensus::Dependent.new(
        last_name: "Johnson", first_name: "Matt", dob: "01/12/2011", ssn: "422233311", employee_relationship: "child_under_26"
        ),
      EmployerCensus::Dependent.new(
        last_name: "Johnson", first_name: "Mark", dob: "03/12/1978", ssn: "521233311", employee_relationship: "spouse"
        ),
      EmployerCensus::Dependent.new(
        last_name: "Johnson", first_name: "Caroline", dob: "04/01/2008", ssn: "621233321", employee_relationship: "child_under_26"
        )
    ]
  )

org_2_employer_profile = org_2.create_employer_profile(
    entity_kind: "c_corporation",
    broker_agency_profile: broker_agency_1,
    employee_families: [org_2_jetson]
  )

org_2_plan_year = org_2_employer_profile.plan_years.build(
    start_on: 0.days.ago.beginning_of_year.to_date,
    end_on: 0.days.ago.end_of_year.to_date,
    open_enrollment_start_on: (0.days.ago.beginning_of_year.to_date - 2.months).beginning_of_month,
    open_enrollment_end_on: (0.days.ago.beginning_of_year.to_date - 2.months).end_of_month,
    fte_count: 12,
    pte_count: 1
  )

org_2_plan = Plan.create(
    active_year: 2015,
    hios_id: "194303",
    name: "Aetna 8913 Silver 900",
    coverage_kind: "health",
    metal_level: "gold",
    market: "shop",
    carrier_profile_id: CarrierProfile.first.id
  )

org_2_benefit_group = org_2_plan_year.benefit_groups.build(
    effective_on_kind:  "date_of_hire",
    terminate_on_kind:  "end_of_month",
    effective_on_offset:  30,
    premium_pct_as_int:   70,
    employer_max_amt_in_cents:  500_00,
    reference_plan: org_2_plan
  )

org_2_benefit_group.relationship_benefits.build(
    relationship: "employee",
    premium_pct: 65,
    employer_max_amt: 100.00
  )
org_2.save!

puts "::: Employers seed complete :::"
puts "*"*80
