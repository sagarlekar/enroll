class HbxProfile
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :organization
  embeds_many :enrollment_periods

  field :markets, type: Array, default: []

  Name = "DC HealthLink"
  CmsId = "DC0"

  ## Application-level caching

  ## Carriers
  # hbx_id, hbx_carrier_id, name, abbrev, 

  ## Plans & Premiums
  # hbx_id, hbx_plan_id, hbx_carrier_id, hios_id, year, quarter, name, abbrev, market, type, metal_level, pdf

  ## Cross-reference ID Directory
  # Person
  # Employer
  # BrokerAgency
  # Policy

  ## HBX Policies for IVL Market
  # Open Enrollment periods

  ## SHOP Market HBX Policies
  # Employer Contribution Strategies


  # Maximum number of days an Employer may notify HBX of termination 
  # may terminate an employee and effective date
  ShopRetroactiveTerminationMaximumInDays = 60

  # Number of days preceeding effective date that an employee may submit a plan enrollment 
  ShopMaximumEnrollmentPeriodBeforeEligibilityInDays = 30

  # Minimum number of days an employee may submit a plan, following addition or correction to Employer roster
  ShopMinimumEnrollmentPeriodAfterRosterEntryInDays = 30

end

class HbxPolicyError < StandardError; end
