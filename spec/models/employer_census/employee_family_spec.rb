require 'rails_helper'

# Should only be one active employee_family per employer at one time
# terminate employee must set the employee family inactive
# replicate_for_rehire_for_rehire

describe EmployerCensus::EmployeeFamily, type: :model do
  it { should validate_presence_of :census_employee }

  let(:employer_profile) {FactoryGirl.create(:employer_profile)}
  let(:census_employee) {FactoryGirl.build(:employer_census_employee)}

  describe ".new" do
    let(:valid_params) do
      {
        employer_profile: employer_profile,
        census_employee: census_employee
      }
    end

    context "with no arguments" do
      let(:params) {{}}

      it "should not save" do
        expect(EmployerCensus::EmployeeFamily.new(**params).save).to be_falsey
      end
    end

    context "with no employer_profile" do
      let(:params) {valid_params.except(:employer_profile)}

      it "should raise" do
        expect{EmployerCensus::EmployeeFamily.create(**params)}.to raise_error(Mongoid::Errors::NoParent)
      end
    end

    context "with no census_employee" do
      let(:params) {valid_params.except(:census_employee)}

      it "should fail validation" do
        expect(EmployerCensus::EmployeeFamily.create(**params).errors[:census_employee].any?).to be_truthy
      end
    end

    context "with all required data" do
      let(:params) {valid_params}
      let(:census_family) {EmployerCensus::EmployeeFamily.new(**params)}

      it "should successfully save" do
        expect(census_family.save).to be_truthy
      end

      context "and it is saved" do
        before do
          census_family.save
        end

        it "should not be linked" do
          expect(census_family.is_linked?).to be_falsey
        end

        it "should be linkable" do
          expect(census_family.is_linkable?).to be_truthy
        end
      end
    end
  end
end

describe EmployerCensus::EmployeeFamily, 'class methods' do
  def employer_profile; FactoryGirl.create(:employer_profile); end
  def employee_family;  FactoryGirl.create(:employer_census_family, employer_profile: employer_profile); end
  def census_employee;  employee_family.census_employee; end
  def employee_role;    FactoryGirl.build(:employee_role, ssn: census_employee.ssn, dob: census_employee.dob); end

  describe ".id" do
    it "should return nil if no census family present " do
      expect(EmployerCensus::EmployeeFamily.find(EmployerCensus::EmployeeFamily.new.id)).to be_nil
    end
    it "should return census family object" do
      expect(EmployerCensus::EmployeeFamily.find(employee_family.id)).to be_an_instance_of EmployerCensus::EmployeeFamily
    end
  end

  describe ".find_by_employee_role" do
    context "and there's no matching employee_role in employee_families" do
      it "should return nil" do
        expect(EmployerCensus::EmployeeFamily.find_by_employee_role(employee_role)).to be_nil
      end
    end

    context "and a matching employee_role exists" do
      let!(:saved_employee_role) do
        employee_role.save
        employee_role
      end

      context "and employee_role is not linked to census_family" do
        it "should return nil" do
          expect(EmployerCensus::EmployeeFamily.find_by_employee_role(saved_employee_role)).to be_nil
        end
      end

      context "and employee_role is linked to census_family" do
        let(:linked_employee_family) { employee_family.link_employee_role(saved_employee_role) }

        it "should return matching EmployeeFamily instance" do
          expect(linked_employee_family.is_linked?).to be_truthy
          linked_employee_family.save
          # expect(linked_employee_family).to eq ""
          expect(EmployerCensus::EmployeeFamily.find_by_employee_role(saved_employee_role)).to be_an_instance_of EmployerCensus::EmployeeFamily
          expect(EmployerCensus::EmployeeFamily.find_by_employee_role(saved_employee_role).census_employee.ssn.to_i).to eq employee_role.ssn.to_i-1
        end
      end
    end
  end
end

describe EmployerCensus::EmployeeFamily, 'instance methods' do

  let(:employer_profile) {FactoryGirl.create(:employer_profile)}
  let(:employee_role) {FactoryGirl.build(:employee_role)}
  let(:census_family) {FactoryGirl.build(:employer_census_family)}
  let(:census_employee) { census_family.census_employee }

  describe '#link_employee_role' do

    context "and employee is linked" do
      before do
        census_family.save
        census_family.link_employee_role(employee_role)
      end

      it "should raise an error" do
        expect{census_family.link_employee_role(employee_role)}.to raise_error(EmployeeFamilyLinkError)
      end
    end

    context "and employee is terminated" do
      before do
        census_family.terminate(Date.today)
      end

      it "should raise an error" do
        expect{census_family.link_employee_role(employee_role)}.to raise_error(EmployeeFamilyLinkError)
      end
    end

    context "and the eligibility date is too far in future" do

      pending "use HbxProfile:ShopMaximumEnrollmentPeriodBeforeEligibilityInDays"
      it "should" do
      end
    end

    context "and the special enrollment period has expired" do

      pending "use HbxProfile:ShopMinimumEnrollmentPeriodAfterRosterEntryInDays"
      context "and the employee's roster entry wasn't timely" do
      end
    end

    context "with a valid employee" do
      before do
        employer_profile.employee_families = [census_family]
        census_family.link_employee_role(employee_role)
      end

      it 'should link to the employee' do
        expect(census_family.is_linked?).to be_truthy
        expect(census_family.is_linkable?).to be_falsey
        expect(census_family.employee_role_id).to eq employee_role.id
        expect(employer_profile.employee_families.first.employee_role_id).to eq employee_role._id
      end
    end
  end

  # describe "#delink_employee_role" do

  #   context "and it isn't linked" do
  #     it "should return the employee_family" do
  #       expect(census_family.delink_employee_role).to be_an_instance_of EmployerCensus::EmployeeFamily
  #     end
  #   end

  #   context "and it is linked" do
  #     before do
  #       census_family.link_employee_role(employee_role)
  #     end

  #     it "should make it linkable" do
  #       expect(census_family.delink_employee_role.is_linkable?).to be_truthy
  #     end
  #   end
  # end

  describe '#terminate and #terminate!' do
    let(:valid_termination_date) {Date.today - (maximum_retroactive_termination)}
    let(:maximum_retroactive_termination) {HbxProfile::ShopRetroactiveTerminationMaximumInDays}

    context "termination date > HBX policy for retro terms" do
      let(:overdue_termination_date) {Date.today.beginning_of_month - (maximum_retroactive_termination)}

      context "user role isn't an HBX admin" do
        context "and terminate! is called" do
          it "should raise an error" do
            expect{census_family.terminate!(overdue_termination_date)}.to raise_error(HbxPolicyError)
          end
        end

        context "and terminate is called" do
          it "should return nil" do
            expect(census_family.terminate(overdue_termination_date)).to be_nil
          end
        end
      end

      context "user role is HBX admin" do
        pending "add HBX admin role authorization to override"
        it "should terminate employee" do
          expect(census_family.terminate(valid_termination_date).is_terminated?).to be_truthy
        end
      end
    end

    context "termination date is valid for retro terms" do
      it "should return terminated employee" do
        expect(census_family.terminate(valid_termination_date).is_terminated?).to be_truthy
      end
    end
  end

  describe '#benefit_group' do
    let(:benefit_group) {FactoryGirl.create(:benefit_group)}

    it 'sets benefit_group' do
      census_family.benefit_group = benefit_group
      expect(census_family.benefit_group_id).to eq benefit_group.id
      expect(census_family.plan_year_id).to eq benefit_group.plan_year.id
    end

    it 'gets benefit_group' do
    end
  end

  describe '#plan_year' do
    let(:plan_year) {FactoryGirl.build(:plan_year)}

    it 'sets plan_year' do
      census_family.plan_year = plan_year
      expect(census_family.plan_year_id).to eq plan_year.id
    end

    it 'gets plan_year' do
      census_family.plan_year = plan_year
      census_family.employer_profile.plan_years = [plan_year]
      expect(census_family.plan_year).to be_an_instance_of PlanYear
      expect(census_family.plan_year_id).to eq census_family.employer_profile.plan_years.first.id
    end
  end

  describe '#replicate_for_rehire' do
    it 'copies the family to new instance if the employee is rehired.' do
      census_family.census_employee.hired_on = Date.today - 1.year
      census_family.census_employee.terminated_on = Date.today - 10.days
      census_family.terminated = true
      ditto = census_family.replicate_for_rehire
      expect(ditto).to be_an_instance_of EmployerCensus::EmployeeFamily
      expect(ditto.employee_role_id).to be_nil
      expect(ditto.is_active?).to eq false
      expect(ditto.is_linked?).to eq false

      expect(ditto.census_employee).to eq census_employee
      expect(ditto.census_employee.hired_on).to be_nil
      expect(ditto.census_employee.terminated_on).to be_nil
      expect(ditto.census_employee.address).to eq census_employee.address
    end

    it "does not copy if the employee is already present." do
      ditto = census_family.replicate_for_rehire
      ditto.census_employee.hired_on = 1.year.ago
      employer_profile.employee_families = [ditto]
      employer_profile.save

      ditto_1 = census_family.replicate_for_rehire
      expect(census_family.is_active?).to eq true
      expect(ditto_1).to be_nil
      # expect{census_family.replicate_for_rehire}.to raise_error("EmployerCensus::EmployeeFamily instance is already active")
    end
  end
end
