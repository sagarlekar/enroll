require 'rails_helper'

describe Employee, type: :model do
  it { should delegate_method(:hbx_id).to :person }
  it { should delegate_method(:ssn).to :person }
  it { should delegate_method(:dob).to :person }
  it { should delegate_method(:gender).to :person }

  it { should validate_presence_of :ssn }
  it { should validate_presence_of :dob }
  it { should validate_presence_of :gender }
  it { should validate_presence_of :employer_id }
  it { should validate_presence_of :hired_on }

  let(:ssn) {"987654321"}
  let(:dob) { 36.years.ago.to_date }
  let(:gender) {"female"}
  let(:hired_on) { 10.days.ago.to_date }

  describe "built" do
    let(:address) {FactoryGirl.build(:address)}
    let(:saved_person) {FactoryGirl.create(:person, first_name: "Annie", last_name: "Lennox", addresses: [address])}
    let(:new_person) {FactoryGirl.build(:person, first_name: "Carly", last_name: "Simon")}
    let(:employer) {FactoryGirl.create(:employer)}

    let(:valid_person_attributes) do
      {
        ssn: ssn,
        dob: dob,
        gender: gender,
      }
    end

    let(:valid_params) do
      {
        person_attributes: valid_person_attributes,
        employer: employer,
        hired_on: hired_on,
      }
    end

    context "with valid parameters" do
      let(:employee) {saved_person.employees.build(valid_params)}

      %w[employer ssn dob gender employer hired_on].each do |m|
        it "should have the right #{m}" do
          expect(employee.send(m)).to eq send(m)
        end
      end

    end

    context "with no employer" do
      let(:params) {valid_params.except(:employer)}
      let(:employee) {saved_person.employees.build(params)}
      before() {employee.valid?}

      it "should not be valid" do
        expect(employee.valid?).to be false
      end

      it "should have an error on employer_id" do
        expect(employee.errors[:employer_id].any?).to be true
      end
    end

    context "with no hired_on" do
      let(:params) {valid_params.except(:hired_on)}
      let(:employee) {saved_person.employees.build(params)}
      before() {employee.valid?}

      it "should not be valid" do
        expect(employee.valid?).to be false
      end

      it "should have an error on hired_on" do
        expect(employee.errors[:hired_on].any?).to be true
      end
    end

    context "with no ssn" do
      let(:person_params) {valid_person_attributes.except(:ssn)}
      let(:params) {valid_params.merge(person_attributes: person_params)}
      let(:employee) {saved_person.employees.build(params)}
      before() {employee.valid?}

      it "should not be valid" do
        expect(employee.valid?).to be false
      end

      it "should have an error on ssn" do
        expect(employee.errors[:ssn].any?).to be true
      end
    end

    context "with no gender" do
      let(:person_params) {valid_person_attributes.except(:gender)}
      let(:params) {valid_params.merge(person_attributes: person_params)}
      let(:employee) {saved_person.employees.build(params)}
      before() {employee.valid?}

      it "should not be valid" do
        expect(employee.valid?).to be false
      end

      it "should have an error on gender" do
        expect(employee.errors[:gender].any?).to be true
      end
    end

    context "with no dob" do
      let(:person_params) {valid_person_attributes.except(:dob)}
      let(:params) {valid_params.merge(person_attributes: person_params)}
      let(:employee) {saved_person.employees.build(params)}
      before() {employee.valid?}

      it "should not be valid" do
        expect(employee.valid?).to be false
      end

      it "should have an error on dob" do
        expect(employee.errors[:dob].any?).to be true
      end
    end
  end

  it 'properly intantiates the class using an existing person' do
    pending "replace with pattern"
    ssn = "987654321"
    date_of_hire = Date.today - 10.days
    dob = Date.today - 36.years
    gender = "female"

    employer = Employer.create(
        legal_name: "ACME Widgets, Inc.",
        fein: "098765432",
        entity_kind: :c_corporation
      )

    person = Person.create(
        first_name: "annie",
        last_name: "lennox",
        addresses: [Address.new(
            kind: "home",
            address_1: "441 4th St, NW",
            city: "Washington",
            state: "DC",
            zip: "20001"
          )
        ]
      )

    employee = person.build_employee
    employee.ssn = ssn
    employee.dob = dob
    employee.gender = gender
    employee.employers << employer._id
    employee.date_of_hire = date_of_hire
    expect(employee.touch).to eq true

    # Verify local getter methods
    expect(employee.employers.first).to eq employer._id
    expect(employee.date_of_hire).to eq date_of_hire

    # Verify delegate local attribute values
    expect(employee.ssn).to eq ssn
    expect(employee.dob).to eq dob
    expect(employee.gender).to eq gender

    # Verify delegated attribute values
    expect(person.ssn).to eq ssn
    expect(person.dob).to eq dob
    expect(person.gender).to eq gender

    expect(employee.errors.messages.size).to eq 0
    expect(employee.save).to eq true
  end

  it 'properly intantiates the class using a new person' do
    pending "replace with pattern"
    ssn = "987654320"
    date_of_hire = Date.today - 10.days
    dob = Date.today - 26.years
    gender = "female"

    employer = Employer.create(
        legal_name: "Ace Ventures, Ltd.",
        fein: "098765437",
        entity_kind: "s_corporation"
      )

    person = Person.new(first_name: "carly", last_name: "simon")

    employee = person.build_employee
    employee.ssn = ssn
    employee.dob = dob
    employee.gender = gender
    # employee.employer << employer
    employee.date_of_hire = date_of_hire

    # Verify local getter methods
    # expect(employee.employers.first).to eq employer_.id
    expect(employee.date_of_hire).to eq date_of_hire

    # Verify delegate local attribute values
    expect(employee.ssn).to eq ssn
    expect(employee.dob).to eq dob
    expect(employee.gender).to eq gender

    # Verify delegated attribute values
    expect(person.ssn).to eq ssn
    expect(person.dob).to eq dob
    expect(person.gender).to eq gender

    expect(person.errors.messages.size).to eq 0
    expect(person.save).to eq true

    expect(employee.touch).to eq true
    expect(employee.errors.messages.size).to eq 0
    expect(employee.save).to eq true
  end
  # it "updates instance timestamps" do
  #   er = FactoryGirl.build(:employer)
  #   ee = FactoryGirl.build(:employee)
  #   pn = Person.create(first_name: "Ginger", last_name: "Baker")
  #   # ee = Employee.new(ssn: "345907654", dob: Date.today - 40.years, gender: "male", employer: er, date_of_hire: Date.today)
  #   ee = FactoryGirl.build(:employee)
  #   pn.employees << ee
  #   pn.valid?
  #   expect(ee.errors.messages.inspect).to eq 0
  #   expect(pn.save).to eq true
  #   expect(ee.created_at).to eq ee.updated_at
  #   employee.date_of_termination = Date.today
  #   expect(ee.save).to eq true
  #   expect(ee.created_at).not_to eq ee.updated_at
  # end
end

describe Employee, type: :model do
  let(:person_created_at) { 10.minutes.ago }
  let(:person_updated_at) { 8.minutes.ago }
  let(:employee_created_at) { 9.minutes.ago }
  let(:employee_updated_at) { 7.minutes.ago }
  let(:ssn) { "019283746" }
  let(:dob) { 45.years.ago.to_date }
  let(:hired_on) { 2.years.ago.to_date }
  let(:gender) { "male" }

  context "when created" do
    let(:employer) { FactoryGirl.create(:employer) }

    let(:person) {
      FactoryGirl.create(:person,
        created_at: person_created_at,
        updated_at: person_updated_at
      )
    }

    let(:employee) {
      person.employees.create(
        employer: employer,
        hired_on: hired_on,
        created_at: employee_created_at,
        updated_at: employee_updated_at,
        person_attributes: {
          ssn: ssn,
          dob: dob,
          gender: gender,
        }
      )
    }

    it "parent created_at should be right" do
      expect(person.created_at).to eq person_created_at
    end

    it "parent updated_at should be right" do
      expect(person.updated_at).to eq person_updated_at
    end

    it "created_at should be right" do
      expect(employee.created_at).to eq employee_created_at
    end

    it "updated_at should be right" do
      expect(employee.updated_at).to eq employee_updated_at
    end

    context "then parent updated" do
      let(:middle_name) { "Albert" }
      before do
        person.middle_name = middle_name
        person.save
      end

      it "parent created_at should not have changed" do
        expect(person.created_at).to eq person_created_at
      end

      it "parent updated_at should have changed" do
        expect(person.updated_at).to be > person_updated_at
      end

      it "created_at should not have changed" do
        expect(employee.created_at).to eq employee_created_at
      end

      it "updated_at should not have changed" do
        expect(employee.updated_at).to eq employee_updated_at
      end
    end

    context "then parent touched" do
      before do
        person.touch
      end

      it "parent created_at should not have changed" do
        expect(person.created_at).to eq person_created_at
      end

      it "parent updated_at should not have changed" do
        expect(person.updated_at).to be > person_updated_at
      end

      it "created_at should not have changed" do
        expect(employee.created_at).to eq employee_created_at
      end

      it "updated_at should not have changed" do
        expect(employee.updated_at).to eq employee_updated_at
      end
    end

    context "then a nested parent attribute is updated" do
      before do
        employee.ssn = "647382910"
        employee.save
      end

      it "parent created_at should not have changed" do
        expect(person.created_at).to eq person_created_at
      end

      it "parent updated_at should have changed" do
        expect(person.updated_at).to be > person_updated_at
      end

      it "created_at should not have changed" do
        expect(employee.created_at).to eq employee_created_at
      end

      it "updated_at should not have changed" do
        expect(employee.updated_at).to eq employee_updated_at
      end
    end

    context "then updated" do
      let(:new_hired_on) { 10.days.ago.to_date }

      before do
        employee.hired_on = new_hired_on
        employee.save
      end

      it "parent created_at should not have changed" do
        expect(person.created_at).to eq person_created_at
      end

      it "parent updated_at should have changed" do
        expect(person.updated_at).to be > person_updated_at
      end

      it "created_at should not have changed" do
        expect(employee.created_at).to eq employee_created_at
      end

      it "updated_at should have changed" do
        expect(employee.updated_at).to be > employee_updated_at
      end
    end

    context "then touched" do
      before do
        employee.touch
      end

      it "parent created_at should not have changed" do
        expect(person.created_at).to eq person_created_at
      end

      it "parent updated_at should have changed" do
        expect(person.updated_at).to be > person_updated_at
      end

      it "created_at should not have changed" do
        expect(employee.created_at).to eq employee_created_at
      end

      it "updated_at should have changed" do
        expect(employee.updated_at).to be > employee_updated_at
      end
    end
  end
end
