require 'rails_helper'

RSpec.describe Consumer::EmployeeRolesController, :dbclean => :after_each do
  describe "PUT update" do
    let(:employee_role_id) { "123455555" }
    let(:person_parameters) { { :first_name => "SOMDFINKETHING", :employee_role_id => employee_role_id} }
    let(:organization_id) { "1234324234" }
    let(:person_id) { "4324324234" }
    let(:benefit_group) { double }
    let(:census_employee) { double(:hired_on => "whatever" ) }
    let(:employer_profile) { double }
    let(:census_family) { double(:census_employee => census_employee) }
    let(:effective_date) { double }
    let(:person_id) { "5234234" }
    let(:employee_role) { double(:id => employee_role_id, :employer_profile => employer_profile, :benefit_group => benefit_group, :census_family => census_family) }
    let(:person) { Person.new }
    let(:role_form) {
      Forms::EmployeeRole.new(person, employee_role)
    }

    before(:each) do
      sign_in
      allow(Person).to receive(:find).with(person_id).and_return(person)
      allow(person).to receive(:employee_roles).and_return([employee_role])
      allow(Forms::EmployeeRole).to receive(:new).with(person, employee_role).and_return(role_form)
      allow(benefit_group).to receive(:effective_on_for).with("whatever").and_return(effective_date)
      allow(role_form).to receive(:update_attributes).with(person_parameters).and_return(save_result)
      put :update, :person => person_parameters, :id => person_id
    end

    describe "given valid person parameters" do
      let(:save_result) { true }

      it "should redirect to dependent_details" do
        expect(response).to have_http_status(:success)
        expect(response).to render_template("dependent_details")
      end
    end

    describe "given invalid person parameters" do
      let(:save_result) { false }

      it "should render edit" do
        expect(response).to have_http_status(:success)
        expect(response).to render_template("edit")
        expect(assigns(:person)).to eq role_form
        expect(assigns[:effective_on]).to eq effective_date
        expect(assigns[:benefit_group]).to eq benefit_group
        expect(assigns[:census_family]).to eq census_family
        expect(assigns[:employer_profile]).to eq employer_profile
      end
    end
  end
  describe "POST create" do
    let(:person) { Person.new }
    let(:hired_on) { double }
    let(:family) { double }
    let(:benefit_group) { instance_double("BenefitGroup") }
    let(:employer_profile) { double }
    let(:census_employee) { instance_double("EmployerCensus::Employee", :hired_on => hired_on ) }
    let(:census_family) { instance_double("EmployerCensus::EmployeeFamily", :census_employee => census_employee, :employer_profile => employer_profile) }
    let(:employee_role) { instance_double("EmployeeRole", :benefit_group => benefit_group, :census_family => census_family, :person => person, :id => "212342345") }
    let(:effective_date) { double }
    let(:employment_relationship) {
      instance_double("Forms::EmploymentRelationship", {
             :employee_family => census_family
      } )
    }
    let(:employment_relationship_properties) { { :skllkjasdfjksd => "a3r123rvf" } }
    let(:user) { double }

    before :each do
      allow(Forms::EmploymentRelationship).to receive(:new).with(employment_relationship_properties).and_return(employment_relationship)
      allow(Factories::EnrollmentFactory).to receive(:construct_employee_role).with(user, census_family, employment_relationship).and_return([employee_role, family])
      allow(benefit_group).to receive(:effective_on_for).with(hired_on).and_return(effective_date)
      sign_in(user)
      post :create, :employment_relationship => employment_relationship_properties
    end

    it "should render the edit template" do
      expect(response).to have_http_status(:success)
      expect(response).to render_template("edit")
    end

    it "should assign the employee_role" do
      expect(assigns(:employee_role)).to eq employee_role
    end

    it "should assign the person" do
      expect(assigns(:person)).to eq person
    end

    it "should assign the family" do
      expect(assigns(:family)).to eq family
    end

    it "should assign the 9 billion other properties required by the legacy template" do
      expect(assigns(:census_family)).to eq census_family
      expect(assigns(:benefit_group)).to eq benefit_group
      expect(assigns(:census_employee)).to eq census_employee
      expect(assigns(:effective_on)).to eq effective_date
    end
  end

  describe "POST match" do
    let(:person_parameters) { { :first_name => "SOMDFINKETHING" } }
    let(:mock_employee_candidate) { instance_double("Forms::EmployeeCandidate", :valid? => validation_result) }
    let(:hired_on) { double }
    let(:found_families) { [] }
    let(:employment_relationships) { double }

    before(:each) do
      sign_in
      allow(Forms::EmployeeCandidate).to receive(:new).with(person_parameters).and_return(mock_employee_candidate)
      allow(EmployerProfile).to receive(:find_census_families_by_person).with(mock_employee_candidate).and_return(found_families)
      allow(Factories::EmploymentRelationshipFactory).to receive(:build).with(mock_employee_candidate, found_families).and_return(employment_relationships)
      post :match, :person => person_parameters
    end

    context "given invalid parameters" do
      let(:validation_result) { false }
      it "renders the 'search' template" do
        expect(response).to have_http_status(:success)
        expect(response).to render_template("search")
        expect(assigns[:employee_candidate]).to eq mock_employee_candidate
      end
    end

    context "given valid parameters" do
      let(:validation_result) { true }

      context "but with no found employee" do
        it "renders the 'no_match' template" do
          expect(response).to have_http_status(:success)
          expect(response).to render_template("no_match")
          expect(assigns[:employee_candidate]).to eq mock_employee_candidate
        end

        context "that find a matching employee" do
          let(:found_families) { [instance_double("EmployerCensus::EmployeeFamily")]}

          it "renders the 'match' template" do
            expect(response).to have_http_status(:success)
            expect(response).to render_template("match")
            expect(assigns[:employee_candidate]).to eq mock_employee_candidate
            expect(assigns[:employment_relationships]).to eq employment_relationships
          end
        end
      end
    end
  end

  describe "GET search" do

    before(:each) do
      sign_in
      get :search
    end

    it "renders the 'search' template" do
      expect(response).to have_http_status(:success)
      expect(response).to render_template("search")
      expect(assigns[:person]).to be_a(Forms::EmployeeCandidate)
    end
  end

  describe "GET welcome" do
    let(:user) { double("user") }
    let(:person) { double("person")}

    it "renders the 'welcome' template when user has no employee role" do
      allow(user).to receive(:has_employee_role?).and_return(false)
      sign_in(user)
      get :welcome
      expect(response).to have_http_status(:success)
      expect(response).to render_template("welcome")
    end

    it "renders the 'my account' template when user has employee role" do
      allow(user).to receive(:has_employee_role?).and_return(true)
      allow(user).to receive(:person).and_return(person)
      sign_in(user)
      get :welcome
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(person_my_account_path(person))
    end

  end
end
