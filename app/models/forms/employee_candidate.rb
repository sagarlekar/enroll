module Forms
  class EmployeeCandidate
    include ActiveModel::Model
    include ActiveModel::Validations

    include PeopleNames
    include SsnField
    attr_accessor :gender

    attr_accessor :user_id

    validates_presence_of :first_name, :allow_blank => nil
    validates_presence_of :last_name, :allow_blank => nil
    validates_presence_of :gender, :allow_blank => nil
    include ::Forms::DateOfBirthField
    include Validations::USDate.on(:date_of_birth)

    validates :ssn,
              length: { minimum: 9, maximum: 9, message: "SSN must be 9 digits" },
              numericality: true
   
    def match_census_employees
      census_employees = []
      employers = Organization.where({
        "employer_profile.employee_families" =>  { "$elemMatch" => { 
           "census_employee.dob" => dob,
           "census_employee.ssn" => ssn,
           "linked_at" => nil} }
      })
      employers.each do |emp|
        emp.employer_profile.employee_families.each do |ef|
           ce = ef.census_employee
           if (ce.ssn == ssn) && (ce.dob == dob) && (ef.linked_at.blank?)
             census_employees << ce
           end
        end
      end
      census_employees
    end

    def match_person
      Person.where({
        :dob => dob,
        :ssn => ssn        
      }).first
    end

    def persisted?
      false
    end
  end
end
