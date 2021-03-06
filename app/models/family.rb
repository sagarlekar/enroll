class Family
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning

  Kinds = %W[unassisted_qhp insurance_assisted_qhp employer_sponsored streamlined_medicaid emergency_medicaid hcr_chip]
  ImmediateFamily = %w{self spouse life_partner child ward foster_child adopted_child stepson_or_stepdaughter}

  auto_increment :hbx_assigned_id, seed: 9999

  field :e_case_id, type: String # Eligibility system foreign key
  field :e_status_code, type: String
  field :application_type, type: String
  field :renewal_consent_through_year, type: Integer # Authorize auto-renewal elibility check through this year (CCYY format)

  field :is_active, type: Boolean, default: true # ApplicationGroup active on the Exchange?
  field :submitted_at, type: DateTime # Date application was created on authority system
  field :updated_by, type: String

  # All current and former members of this group
  belongs_to  :person
  embeds_many :family_members, cascade_callbacks: true
  embeds_many :special_enrollment_periods, cascade_callbacks: true
  embeds_many :irs_groups, cascade_callbacks: true
  embeds_many :households, cascade_callbacks: true, :before_add => :reset_active_household

  accepts_nested_attributes_for :special_enrollment_periods, :family_members, :irs_groups, :households

  index({person_id: 1})
  index({e_case_id: 1}, { unique: true, sparse: true })
  index({is_active: 1})
  index({submitted_at: 1})

  # child model indexes
  index({"family_member._id" => 1}, { unique: true, sparse: true })
  index({"family_member.person_id" => 1})
  index({"family_member.broker_role_id" => 1})
  index({"family_member.is_primary_applicant" => 1})
  index({"family_member.hbx_enrollment_exemption.certificate_number" => 1})
  index({"household.hbx_enrollment.broker_agency_id" => 1}, {sparse: true})
  index({"household.hbx_enrollment.policy_id" => 1}, { unique: true, sparse: true })
  index({"household.tax_household.hbx_assigned_id" => 1})
  index({"household.tax_household.tax_household_member.financial_statement.submitted_date" => 1})
  index({"irs_group.hbx_assigned_id" => 1})

  validates :renewal_consent_through_year,
            numericality: {only_integer: true, inclusion: 2014..2025},
            :allow_nil => true

  validates :e_case_id, uniqueness: true, allow_nil: true
  validate :family_integrity

  after_initialize :build_household

  scope :all_with_multiple_family_members, -> { exists({:'family_members.1' => true}) }

  def latest_household
    return households.first if households.size == 1
    households.order_by(:'submitted_at'.desc).limit(1).only(:households).first
    # persisted_household = households.select(&:persisted?) - [nil] #remove any nils
    # persisted_household.sort_by(&:submitted_at).last
  end

  def primary_family_member
    family_members.detect { |family_member| family_member.is_primary_applicant? && family_member.is_active? }
  end

  def primary_applicant
    primary_family_member
  end

  def consent_applicant
    family_members.detect { |family_member| family_member.is_consent_applicant? && family_member.is_active? }
  end

  def active_family_members
    family_members.find_all { |family_member| family_member.is_active? }
  end

  def find_family_member_by_person(person)
    family_members.detect { |family_member| family_member.person_id == person._id }
  end

  # Life events trigger special enrollment periods
  def is_under_special_enrollment_period?
    return false if special_enrollment_periods.size == 0
    sep = special_enrollment_periods.order_by(:begin_on.desc).limit(1).only(:special_enrollment_periods).first
    sep.is_active?
  end

  def current_special_enrollment_periods
    return [] if special_enrollment_periods.size == 0
    seps = special_enrollment_periods.order_by(:begin_on.desc).only(:special_enrollment_periods)
    seps.reduce([]) { |list, event| list << event if event.is_active?; list }
  end

  # List of SEPs active for this Application Group today, or passed date
  def active_seps(day = Date.today)
    special_enrollment_periods.find_all { |sep| (sep.start_date..sep.end_date).include?(day) }
  end

  # single SEP with latest end date from list of active SEPs
  def current_sep
    active_seps.max { |sep| sep.end_date }
  end

  def active_broker_roles
    active_household.hbx_enrollments.reduce([]) { |b, e| b << e.broker_role if e.is_active? && !e.broker_role.blank? } || []
  end

  def build_from_employee_role(employee_role)
    add_family_member(employee_role.person, is_primary_applicant: true)
    employee_role.person.person_relationships.each { |kin| add_family_member(kin.relative) }
    self
  end

  def relate_new_member(person, relationship)
    primary_applicant_person.ensure_relationship_with(person, relationship)
    add_family_member(person)
  end

  def add_family_member(person, **opts)
#    raise ArgumentError.new("expected Person") unless person.is_a? Person

    is_primary_applicant     = opts[:is_primary_applicant]  || false
    is_coverage_applicant    = opts[:is_coverage_applicant] || true
    is_consent_applicant     = opts[:is_consent_applicant]  || false

    family_member = family_members.build(
        person: person, 
        is_primary_applicant: is_primary_applicant,
        is_coverage_applicant: is_coverage_applicant,
        is_consent_applicant: is_consent_applicant
      )

    active_household.add_household_coverage_member(family_member)
    family_member
  end

  def remove_family_member(person)
    family_member = find_family_member_by_person(person)
    if family_member.present?
      family_member.is_active = false
      # active_household.remove_family_member(family_member)
    end
    
    family_member
  end

  def person_is_family_member?(person)
    find_family_member_by_person(person).present?
  end

  def active_household
    households.detect { |household| household.is_active? }
  end

  def dependents
    family_members.reject(&:is_primary_applicant)
  end

  def people_relationship_map
    map = Hash.new
    people.each do |person|
      map[person] = person_relationships.detect { |r| r.object_person == person.id }.relationship_kind
    end
    map
  end

  def is_active?
    self.is_active
  end

  def find_matching_inactive_member(personish)
    inactive_members = family_members.reject(&:is_active)
    return nil if inactive_members.blank?
    if !personish.ssn.blank?
      inactive_members.detect { |mem| mem.person.ssn == personish.ssn }
    else
      return nil if personish.dob.blank?
      search_dob = personish.dob.strftime("%m/%d/%Y")
      inactive_members.detect do |mem|
        mp = mem.person
        mem_dob = mem.dob.blank? ? nil : mem.dob.strftime("%m/%d/%Y")
        (personish.last_name.downcase.strip == mp.last_name.downcase.strip) &&
          (personish.first_name.downcase.strip == mp.first_name.downcase.strip) &&
          (search_dob == mem_dob)
      end
    end
  end

  class << self
    def default_search_order
      [
          ["primary_applicant.name_last", 1],
          ["primary_applicant.name_first", 1]
      ]
    end

    def find_or_build_from_employee_role(new_employee_role)
      existing_family = Family.find_by_employee_role(new_employee_role)

      if existing_family.present?
        existing_family
      else
        family = Family.new
        family.build_from_employee_role(new_employee_role)

        family.save!
        family
      end
    end

    # TODO: should probably go away assuming 1 person should only have 1 family with them as primary
    def find_all_by_primary_applicant(person)
      Family.find_all_by_person(person).select() { |f| f.primary_applicant.person.id.to_s == person.id.to_s }
    end

    def find_by_primary_family_member(person)
      find_all_by_primary_applicant(person).first
    end

    def find_by_employee_role(employee_role)
      find_all_by_primary_applicant(employee_role.person).first
    end

    def find_by_primary_applicant(person)
      find_all_by_primary_applicant(person).first
    end

    def find_all_by_person(person)
      Family.where("family_members.person_id" => person.id)
    end

    def find_family_member(family_member_id)
      family = Family.where("family_members._id" => BSON::ObjectId.from_string(family_member_id)).first
      family.family_members.detect { |member| member._id.to_s == family_member_id.to_s }
    end

    def find_by_case_id(case_id)
      where({"e_case_id" => case_id}).first
    end
  end

private
  def build_household
    if households.size == 0
      irs_group = initialize_irs_group
      initialize_household(irs_group)
    end
  end

  def family_integrity
    only_one_active_primary_family
    single_primary_family_member
    all_family_member_relations_defined
    single_active_household
    no_duplicate_family_members
  end

  def primary_applicant_person
    return nil unless primary_applicant.present?
    primary_applicant.person
  end

  def only_one_active_primary_family
    return unless primary_family_member.present? && primary_family_member.person.present?
    families_with_same_primary = Family.where(
      "family_members" => {
        "$elemMatch" => {
          "is_primary_applicant" => true,
          "person_id" => BSON::ObjectId.from_string(primary_family_member.person_id.to_s)
        }
      },
      "is_active" => true
    )
    if (families_with_same_primary.any? { |fam| fam.id.to_s != self.id.to_s })
      self.errors.add(:base, "has another active family with the same primary applicant")
    end
  end

  def single_primary_family_member
    list = family_members.reduce([]) { |list, family_member| list << family_member if family_member.is_primary_applicant?; list }
    self.errors.add(:family_members, "one family member must be primary family member") if list.size == 0
    self.errors.add(:family_members, "may not have more than one primary family member") if list.size > 1
  end

  def all_family_member_relations_defined
    return unless primary_family_member.present? && primary_family_member.person.present?
    primary_member_id = primary_family_member.id
    primary_person = primary_family_member.person
    other_family_members = family_members.select { |fm| (fm.id.to_s != primary_member_id.to_s) && fm.person.present? }
    undefined_relations = other_family_members.any? { |fm| primary_person.find_relationship_with(fm.person).blank? } 
    errors.add(:family_members, "relationships between primary_family_member and all family_members must be defined") if undefined_relations
  end

  def single_active_household
    list = households.reduce([]) { |list, household| list << household if household.is_active?; list }
    self.errors.add(:households, "one household must be active") if list.size == 0
    self.errors.add(:households, "may not have more than one active household") if list.size > 1
  end

  def initialize_irs_group
    irs_groups.build(effective_starting_on: Date.current)
  end

  def initialize_household(irs_group)
    households.build(irs_group: irs_group, effective_starting_on: irs_group.effective_starting_on, submitted_at: DateTime.current)
  end

  def no_duplicate_family_members
    family_members.group_by { |appl| appl.person_id }.select { |k, v| v.size > 1 }.each_pair do |k, v|
      errors.add(:family_members, "Duplicate family_members for person: #{k}\n" +
                          "family_members: #{v.inspect}")
    end
  end

  # This method will return true only if all the family_members in tax_household_members and coverage_household_members are present in self.family_members
  def integrity_of_family_member_objects
    return true if self.households.blank?

    family_members_in_family = self.family_members - [nil]
    tax_household_family_members_valid = are_arrays_of_family_members_same?(family_members_in_family.map(&:id), self.households.flat_map(&:tax_households).flat_map(&:tax_household_members).map(&:applicant_id))
    coverage_family_members_valid = are_arrays_of_family_members_same?(family_members_in_family.map(&:id), self.households.flat_map(&:coverage_households).flat_map(&:coverage_household_members).map(&:applicant_id))
    tax_household_family_members_valid && coverage_family_members_valid
  end

  def are_arrays_of_family_members_same?(base_set, test_set)
    base_set.uniq.sort == test_set.uniq.sort
  end

  def reset_active_household(new_household)
    households.each do |household|
      household.is_active = false
    end
    new_household.is_active = true
  end

  def valid_relationship?(family_member)
    return true if primary_applicant.nil? #responsible party case
    return true if primary_applicant.person.id == family_member.person.id

    if ImmediateFamily.include? primary_applicant.person.find_relationship_with(family_member.person)
      return true
    else
      return false
    end
  end
end
