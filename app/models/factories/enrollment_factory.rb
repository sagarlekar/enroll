module Factories
  class EnrollmentFactory
    def self.add_consumer_role(person:, new_ssn: nil, new_dob: nil, new_gender: nil, new_is_incarcerated:, new_is_applicant:,
                               new_is_state_resident:, new_citizen_status:)

      [:new_is_incarcerated, :new_is_applicant, :new_is_state_resident, :new_citizen_status].each do |value|
        name = value.id2name
        raise ArgumentError.new("missing value: #{name}, expected as keyword ") if eval(name).blank?
      end

      ssn = new_ssn
      dob = new_dob
      gender = new_gender
      is_incarcerated = new_is_incarcerated
      is_applicant = new_is_applicant
      is_state_resident = new_is_state_resident
      citizen_status = new_citizen_status

      # Assign consumer-specifc attributes
      consumer_role = person.build_consumer_role(ssn: ssn,
                                                 dob: dob,
                                                 gender: gender,
                                                 is_incarcerated: is_incarcerated,
                                                 is_applicant: is_applicant,
                                                 is_state_resident: is_state_resident,
                                                 citizen_status: citizen_status)
     if person.save
        consumer_role.save
      else
        consumer_role.errors.add(:person, "unable to update person")
      end

     return consumer_role

    end

    def self.add_broker_role(person:, new_kind:, new_npn:, new_mailing_address:)

      [:new_kind, :new_npn, :new_mailing_address].each do |value|
        name = value.id2name

        raise ArgumentError.new("missing value: #{name}, expected as keyword ") if eval(name).blank?
      end

      kind = new_kind
      npn = new_npn

      mailing_address = new_mailing_address

      family, = self.initialize_family(person, [])

      broker_role = nil

      if person.broker_role.blank?
        # Assign broker-specifc attributes
        #broker_role = person.build_broker(mailing_address: mailing_address, npn: npn, kind: kind)
        broker_role = person.build_broker_role(npn: npn)
      end

      if person.save
        if family.save
          family.delete unless broker_role.save
        else
          broker_role.errors.add(:family, "unable to create family")
        end
      else
        broker_role.errors.add(:person, "unable to update person")
      end

      # Return new instance
      return broker_role

    end

    # Fix this method to utilize the following:
    # needs:
    #   an object that responds to the names and gender methods
    #   employee_family
    #   user
    def self.construct_employee_role(user, employer_census_family, person_details)
      person, person_new = initialize_person(
        user, person_details.name_pfx, person_details.first_name,
        person_details.middle_name, person_details.last_name,
        person_details.name_sfx, employer_census_family.census_employee_ssn,
        employer_census_family.census_employee_dob, person_details.gender
        )
      self.build_employee_role(
        person, person_new, employer_census_family.employer_profile,
        employer_census_family, employer_census_family.hired_on
        )
    end

    def self.add_employee_role(user: nil, employer_profile:,
          name_pfx: nil, first_name:, middle_name: nil, last_name:, name_sfx: nil,
          ssn:, dob:, gender:, hired_on:
      )
      person, person_new = initialize_person(user, name_pfx, first_name, middle_name,
                                             last_name, name_sfx, ssn, dob, gender)

      employer_census_family = employer_profile.linkable_employee_family_by_person(person)

      raise ArgumentError.new("employee_family does not exist for provided person details") unless employer_census_family.present?

      self.build_employee_role(
        person, person_new, employer_profile, employer_census_family, hired_on
        )
    end

    def self.link_employee_family(census_family, employee_role, linked_at = Time.now)
      census_family.link_employee_role(employee_role, linked_at)
      [:employer_profile_id,
       :benefit_group_id,
       :hired_on,
       :terminated_on,
      ].each do |property|
        employee_role.send("#{property}=", census_family.send(property))
      end
    end

    private

    def self.build_employee_role(person, person_new, employer_profile, employer_census_family, hired_on)
      role = find_or_build_employee_role(person, employer_profile, employer_census_family, hired_on)
      self.link_employee_family(employer_census_family, role)
      family, primary_applicant = self.initialize_family(person, employer_census_family.census_dependents)
      saved = save_all_or_delete_new(family, primary_applicant, role)
      if saved
        employer_census_family.save
      elsif person_new
        person.delete
      end
      return role, family
    end

    def self.initialize_person(user, name_pfx, first_name, middle_name,
                               last_name, name_sfx, ssn, dob, gender)
      people = Person.match_by_id_info(ssn: ssn)
      person, is_new = nil, nil
      case people.count
      when 1
        person = people.first
        person.user = user if user
        person.save
        person, is_new = person, false
      when 0
        person, is_new = Person.create(
          user: user,
          name_pfx: name_pfx,
          first_name: first_name,
          middle_name: middle_name,
          last_name: last_name,
          name_sfx: name_sfx,
          ssn: ssn,
          dob: dob,
          gender: gender,
        ), true
      else
        # what am I doing here?  More than one person had the same SSN?
        return nil, nil
      end
      if user.present?
        user.roles << "Employee"
        user.save
      end
      return person, is_new
    end

    def self.find_or_build_employee_role(person, employer_profile, employer_census_family, hired_on)
      roles = person.employee_roles.where(
          "employer_profile_id" => employer_profile.id.to_s,
          "hired_on" => employer_census_family.census_employee.hired_on
        )

      role = case roles.count
      when 0
        # Assign employee-specifc attributes
        person.employee_roles.build(employer_profile: employer_profile, hired_on: hired_on)
      when 1
        roles.first
      else
        # What am I doing here?
        nil
      end
    end

    def self.initialize_family(person, dependents)
      family = person.primary_family
      family = Family.new if family.blank?
      applicant = family.primary_applicant
      applicant = initialize_primary_applicant(family, person) if applicant.blank?
      dependents.each do |dependent|
        initialize_dependent(family, person, dependent)
      end
      return family, applicant
    end

    def self.initialize_primary_applicant(family, person)
      family.add_family_member(person, is_primary_applicant: true) unless family.find_family_member_by_person(person)
    end

    def self.initialize_dependent(family, primary, dependent)
      person, new_person = initialize_person(nil, nil, dependent.first_name,
                                 dependent.middle_name, dependent.last_name,
                                 dependent.name_sfx, dependent.ssn,
                                 dependent.dob, dependent.gender)
      relationship = person_relationship_for(dependent.employee_relationship)
      primary.ensure_relationship_with(person, relationship)
      family.add_family_member(person) unless family.find_family_member_by_person(person)
    end

    def self.person_relationship_for(census_relationship)
      case census_relationship
      when "spouse"
        "spouse"
      when "domestic_parter"
        "life_partner"
      when "child_under_26", "child_26_and_over", "disabled_child_26_and_over"
        "child"
      end
    end

    def self.save_all_or_delete_new(*list)
      objects_to_save = list.reject {|o| !o.changed?}
      num_saved = objects_to_save.count {|o| o.save}
      if num_saved < objects_to_save.count
        objects_to_save.each {|o| o.delete}
        false
      else
        true
      end
    end
  end
end
