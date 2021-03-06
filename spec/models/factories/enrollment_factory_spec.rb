require 'rails_helper'

describe Factories::EnrollmentFactory, "starting with unlinked employee_family and employee_role" do
  let(:benefit_group_id) { "2468" }
  let(:hired_on) { Date.new(2015,1,15) }
  let(:terminated_on) { Date.new(2015,3,25) }

  let(:employer_profile) { EmployerProfile.new }

  let(:census_employee) { EmployerCensus::Employee.new({
    :hired_on => hired_on,
    :terminated_on => terminated_on
  }) }

  let(:census_family) { EmployerCensus::EmployeeFamily.new({
    :census_employee => census_employee,
    :benefit_group_id => benefit_group_id,
    :employer_profile => employer_profile
  }) }

  let(:employee_role) {
    EmployeeRole.new
  }

  describe "After performing the link" do

    before(:each) do
      @linked_at = Time.now
      Factories::EnrollmentFactory.link_employee_family(census_family, employee_role, @linked_at)
    end

    it "should set employee role id on the census_family" do
      expect(census_family.employee_role_id).to eq employee_role.id
    end

    it "should set linked at on the census_family" do
      expect(census_family.linked_at).to eq @linked_at.localtime
    end

    it "should set employer profile id on the employee_role" do
      expect(employee_role.employer_profile_id).to eq employer_profile.id
    end

    it "should set benefit group id on the employee_role" do
      expect(employee_role.benefit_group_id).to eq benefit_group_id
    end

    it "should set census family id on the employee_role" do
      expect(employee_role.census_family_id).to eq census_family.id
    end

    it "should set hired on on the employee_role" do
      expect(employee_role.hired_on).to eq hired_on
    end

    it "should set terminated on on the employee_role" do
      expect(employee_role.terminated_on).to eq terminated_on
    end
  end
end

RSpec.describe Factories::EnrollmentFactory, :dbclean => :after_each do
  let(:employer_profile_without_family) {FactoryGirl.create(:employer_profile)}
  let(:employee_family) {FactoryGirl.create(:employer_census_family)}
  let(:employer_profile) {employee_family.employer_profile}
  let(:census_employee) {employee_family.census_employee}
  let(:user) {FactoryGirl.create(:user)}
  let(:first_name) {census_employee.first_name}
  let(:last_name) {census_employee.last_name}
  let(:ssn) {census_employee.ssn}
  let(:dob) {census_employee.dob}
  let(:gender) {census_employee.gender}
  let(:hired_on) {census_employee.hired_on}

  let(:valid_person_params) do
    {
      user: user,
      first_name: first_name,
      last_name: last_name,
    }
  end
  let(:valid_employee_params) do
    {
      ssn: ssn,
      gender: gender,
      dob: dob,
      hired_on: hired_on
    }
  end
  let(:valid_params) do
    {employer_profile: employer_profile}.merge(valid_person_params).merge(valid_employee_params)
  end

  context "an employer profile exists with an employee and depenedents in the census" do
    let!(:employee_family) {FactoryGirl.create(:employer_census_family_with_dependents)}
    let(:employer_profile) {employee_family.employer_profile}
    let(:census_employee) {employee_family.census_employee}
    let(:user) {FactoryGirl.create(:user)}
    let(:first_name) {census_employee.first_name}
    let(:last_name) {census_employee.last_name}
    let(:ssn) {census_employee.ssn}
    let(:dob) {census_employee.dob}
    let(:gender) {census_employee.gender}
    let(:hired_on) {census_employee.hired_on}
    let(:primary_applicant) {@family.primary_applicant}
    let(:params) {valid_params}
    let(:employer_census_families) do
      EmployerProfile.find(employer_profile.id.to_s).employee_families
    end

    context "and no prior person exists" do
      before do
        @user = FactoryGirl.create(:user)
        @employee_family = FactoryGirl.create(:employer_census_family_with_dependents)
        employer_profile = @employee_family.employer_profile
        census_employee = @employee_family.census_employee
        valid_person_params = {
          user: @user,
          first_name: census_employee.first_name,
          last_name: census_employee.last_name,
        }
        valid_employee_params = {
          ssn: census_employee.ssn,
          gender: census_employee.gender,
          dob: census_employee.dob,
          hired_on: census_employee.hired_on
        }
        valid_params = { employer_profile: employer_profile }.merge(
          valid_person_params
        ).merge(valid_employee_params)
        params = valid_params
        @employee_role, @family = Factories::EnrollmentFactory.add_employee_role(**params)
        @primary_applicant = @family.primary_applicant
      end

      it "should have a family" do
        expect(@family).to be_a Family
      end

      it "should be the primary applicant" do
        expect(@employee_role.person).to eq @primary_applicant.person
      end

      it "should have linked the family foobar" do
        expect(@employee_family.linked_employee_role).to eq @employee_role
      end

      it "should have all family_members" do
        expect(@family.family_members.count).to eq (@employee_family.census_dependents.count + 1)
      end
    end

    context "and a prior person exists but is not associated with the user" do

      before do
        @user = FactoryGirl.create(:user)
        employee_family = FactoryGirl.create(:employer_census_family_with_dependents)
        employer_profile = employee_family.employer_profile
        census_employee = employee_family.census_employee
        valid_person_params = {
          user: @user,
          first_name: census_employee.first_name,
          last_name: census_employee.last_name,
        }
        valid_employee_params = {
          ssn: census_employee.ssn,
          gender: census_employee.gender,
          dob: census_employee.dob,
          hired_on: census_employee.hired_on
        }
        valid_params = { employer_profile: employer_profile }.merge(valid_person_params).merge(valid_employee_params)
        params = valid_params
        @person = FactoryGirl.create(:person,
                                     valid_person_params.except(:user).merge(dob: census_employee.dob,
                                                                             ssn: census_employee.ssn))
        @employee_role, @family = Factories::EnrollmentFactory.add_employee_role(**params)
      end

      it "should link the user to the person" do
        expect(@employee_role.person.user).to eq @user
      end

      it "should link the person to the user" do
        expect(@user.person).to eq @person
      end

      it "should add the employee role to the user" do
        expect(@user.roles).to include "Employee"
      end
    end

    context "and another employer profile exists with the same employee and dependents in the census" do
      before do
        @user = FactoryGirl.create(:user)
        employee_family = FactoryGirl.create(:employer_census_family_with_dependents)
        employer_profile = employee_family.employer_profile
        census_employee = employee_family.census_employee
        valid_person_params = {
          user: @user,
          first_name: census_employee.first_name,
          last_name: census_employee.last_name,
        }
        @ssn = census_employee.ssn
        valid_employee_params = {
          ssn: @ssn,
          gender: census_employee.gender,
          dob: census_employee.dob,
          hired_on: census_employee.hired_on
        }
        valid_params = { employer_profile: employer_profile }.merge(valid_person_params).merge(valid_employee_params)
        @first_employee_role, @first_family = Factories::EnrollmentFactory.add_employee_role(**valid_params)

        dependents = employee_family.census_dependents.collect(&:dup)
        employee = census_employee.dup
        second_employee_family = FactoryGirl.create(:employer_census_family, census_employee: employee, census_dependents: dependents)
        second_employer_profile = second_employee_family.employer_profile
        second_census_employee = second_employee_family.census_employee
        @second_params = { employer_profile: second_employer_profile }.merge(valid_person_params).merge(valid_employee_params)
        @second_employee_role, @second_family = Factories::EnrollmentFactory.add_employee_role(**@second_params)
      end

      it "should still have a findable person" do
        people = Person.match_by_id_info(ssn: @ssn)
        expect(people.count).to eq 1
        expect(people.first).to be_a Person
      end

      it "second employee role should be saved" do
        expect(@second_employee_role.persisted?).to be
      end

      it "second family should be saved" do
        expect(@second_family.persisted?).to be
      end

      it "second employee role should be valid" do
        expect(@second_employee_role.valid?).to be
      end

      it "second family should be the first family" do
        expect(@second_family).to eq @first_family
      end
    end
  end

  describe ".add_employee_role" do
    context "when the employee already exists but is not linked" do
      let(:existing_person) {FactoryGirl.create(:person, valid_person_params)}
      let(:employee) {FactoryGirl.create(:employee_role, valid_employee_params.merge(person: existing_person, employer_profile: employer_profile))}
      before {user;employee_family;employee}

      context "with all required data" do
        let(:params) {valid_params}

        it "should not raise" do
          expect{Factories::EnrollmentFactory.add_employee_role(**params)}.not_to raise_error
        end

        context "successfully created" do
          let(:primary_applicant) {family.primary_applicant}
          let(:employer_census_families) do
            EmployerProfile.find(employer_profile.id.to_s).employee_families
          end
          before {@employee_role, @family = Factories::EnrollmentFactory.add_employee_role(**params)}

          it "should return the existing employee" do
            expect(@employee_role.id.to_s).to eq employee.id.to_s
          end

          it "should return a family" do
            expect(@family).to be_a Family
          end
        end
      end
    end

    context "with no arguments" do
      let(:params) {{}}

      it "should raise" do
        expect{Factories::EnrollmentFactory.add_employee_role(**params)}.to raise_error(ArgumentError)
      end
    end

    context 'with no user' do
      let(:params) {valid_params.except(:user)}

      it 'should not raise' do
        expect{Factories::EnrollmentFactory.add_employee_role(**params)}.not_to raise_error
      end
    end

    context 'with no employer_profile' do
      let(:params) {valid_params.except(:employer_profile)}

      it 'should raise' do
        expect{Factories::EnrollmentFactory.add_employee_role(**params)}.to raise_error(ArgumentError)
      end
    end

    context 'with no first_name' do
      let(:params) {valid_params.except(:first_name)}

      it 'should raise' do
        expect{Factories::EnrollmentFactory.add_employee_role(**params)}.to raise_error(ArgumentError)
      end
    end

    context 'with no last_name' do
      let(:params) {valid_params.except(:last_name)}

      it 'should raise' do
        expect{Factories::EnrollmentFactory.add_employee_role(**params)}.to raise_error(ArgumentError)
      end
    end

    context 'with no ssn' do
      let(:params) {valid_params.except(:ssn)}

      it 'should raise' do
        expect{Factories::EnrollmentFactory.add_employee_role(**params)}.to raise_error(ArgumentError)
      end
    end

    context 'with no gender' do
      let(:params) {valid_params.except(:gender)}

      it 'should raise' do
        expect{Factories::EnrollmentFactory.add_employee_role(**params)}.to raise_error(ArgumentError)
      end
    end

    context 'with no dob' do
      let(:params) {valid_params.except(:dob)}

      it 'should raise' do
        expect{Factories::EnrollmentFactory.add_employee_role(**params)}.to raise_error(ArgumentError)
      end
    end

    context 'with no hired_on' do
      let(:params) {valid_params.except(:hired_on)}

      it 'should raise' do
        expect{Factories::EnrollmentFactory.add_employee_role(**params)}.to raise_error(ArgumentError)
      end
    end

    context "with all required data, but employer_profile has no families" do
      let(:params) {valid_params.merge(employer_profile: employer_profile_without_family)}

      it "should raise" do
        expect{Factories::EnrollmentFactory.add_employee_role(**params)}.to raise_error(ArgumentError)
      end
    end

    context "with all required data" do
      let(:params) {valid_params}

      it "should not raise" do
        expect{Factories::EnrollmentFactory.add_employee_role(**params)}.not_to raise_error
      end

      context "successfully created" do
        let(:primary_applicant) {@family.primary_applicant}
        let(:employer_census_families) do
          EmployerProfile.find(employer_profile.id.to_s).employee_families
        end
        before do
          @employee_role, @family = Factories::EnrollmentFactory.add_employee_role(**params)
        end

        it "should have a family" do
          expect(@family).to be_a Family
        end

        it "should be the primary applicant" do
          expect(@employee_role.person).to eq primary_applicant.person
        end

        it "should have linked the family" do
          expect(employee_family.linked_employee_role).to eq @employee_role
        end
      end
    end
  end

  describe ".add_consumer_role" do
    let(:is_incarcerated) {true}
    let(:is_applicant) {true}
    let(:is_state_resident) {true}
    let(:citizen_status) {"us_citizen"}
    let(:valid_person) {FactoryGirl.create(:person)}

    let(:valid_params) do
      { person: valid_person,
        new_is_incarcerated: is_incarcerated,
        new_is_applicant: is_applicant,
        new_is_state_resident: is_state_resident,
        new_ssn: ssn,
        new_dob: dob,
        new_gender: gender,
        new_citizen_status: citizen_status
      }
    end

    context "with no arguments" do
      let(:params) {{}}
      it "should raise" do
        expect{Factories::EnrollmentFactory.add_consumer_role(**params)}.to raise_error(ArgumentError)
      end
    end

    context "with no is_incarcerated" do
      let(:params) {valid_params.except(:new_is_incarcerated)}
      it "should raise" do
        expect{Factories::EnrollmentFactory.add_consumer_role(**params)}.to raise_error(ArgumentError)
      end
    end

    context "with no is_applicant" do
      let(:params) {valid_params.except(:new_is_applicant)}
      it "should raise" do
        expect{Factories::EnrollmentFactory.add_consumer_role(**params)}.to raise_error(ArgumentError)
      end
    end

    context "with no is_state_resident" do
      let(:params) {valid_params.except(:new_is_state_resident)}
      it "should raise" do
        expect{Factories::EnrollmentFactory.add_consumer_role(**params)}.to raise_error(ArgumentError)
      end
    end

    context "with no citizen_status" do
      let(:params) {valid_params.except(:new_citizen_status)}
      it "should raise" do
        expect{Factories::EnrollmentFactory.add_consumer_role(**params)}.to raise_error(ArgumentError)
      end
    end

    context "with all required data" do
      let(:params) {valid_params}
      it "should not raise" do
        expect{Factories::EnrollmentFactory.add_consumer_role(**params)}.not_to raise_error
      end
    end

  end


  describe ".add_broker_role" do
    let(:mailing_address) do
      {
        kind: 'home',
        address_1: 1111,
        address_2: 111,
        city: 'Washington',
        state: 'DC',
        zip: 11111
      }
    end

    let(:npn) {"xyz123xyz"}
    let(:broker_kind) {"broker"}
    let(:valid_params) do
      { person: valid_person,
        new_npn: npn,
        new_kind: broker_kind,
        new_mailing_address: mailing_address
      }
    end
    let(:valid_person) {FactoryGirl.create(:person)}

    context "with no arguments" do
      let(:params) {{}}
      it "should raise" do
        expect{Factories::EnrollmentFactory.add_broker_role(**params)}.to raise_error(ArgumentError)
      end
    end

    context "with all required data" do
      let(:params) {valid_params}
      it "should not raise" do
        expect{Factories::EnrollmentFactory.add_broker_role(**params)}.not_to raise_error
      end
    end

    context "with no npn" do
      let(:params) {valid_params.except(:new_npn)}
      it "should raise" do
        expect{Factories::EnrollmentFactory.add_broker_role(**params)}.to raise_error(ArgumentError)
      end
    end

    context "with no kind" do
      let(:params) {valid_params.except(:new_kind)}
      it "should raise" do
        expect{Factories::EnrollmentFactory.add_broker_role(**params)}.to raise_error(ArgumentError)
      end
    end

    context "with no mailing address" do
      let(:params) {valid_params.except(:new_mailing_address)}
      it "should raise" do
        expect{Factories::EnrollmentFactory.add_broker_role(**params)}.to raise_error(ArgumentError)
      end
    end

  end
end
