@watir
Feature: Create Employer
  In order to offer health and dental insurance benefits to my employees, employers must create and manage an account on the HBX for their organization.  Such organizations are referred to as an Employer
  An Employer Representative 
  Should be able to create an Employer account

    Scenario: An Employer Representative has not signed up on the HBX
      Given I haven't signed up as an HBX user
      When I visit the Employer portal
        And I sign up with valid user data
      Then I should see a successful sign up message
        # And I should see an initial form to enter information about my Employer and myself

    Scenario: Employer Representative has previously signed up on HBX
      Given I have signed up previously through consumer, broker agency or previous visit to the Employer portal with email "example@example.com"
      When I visit the Employer portal to sign in
        And I sign in with valid user data with email example@example.com and password "12345678"
      Then I should see a welcome page with successful sign in message
      #Then i should see fields to search for employer
        #And I should see an initial form with a fieldset for Employer information, including: legal name, DBA, fein, #entity_kind, broker agency, URL, address, and phone
        #And I should see a second fieldset to enter my name and email
        # And My user data from existing the fieldset values are prefilled using data from my existing account
        #And I should see a successful creation message
      #When I click on an employer in the employer list
      #Then I should see the employer information
      #When I click on the Employees tab
      #Then I should see the employee family roster
        #And It should default to active tab
      #When I click on add employee button
      #Then I should see a form to enter information about employee, address and dependents
        #And I should see employer census family created success message
      #When I click on Edit family button for a census family
      #Then I should see a form to update the contents of the census employee
        #And I should see employer census family updated success message
      #When I click on terminate button for a census family
      #Then The census family should be terminated and move to terminated tab
        #And I should see the census family is successfully terminated message
      #When I click on Rehire button for a census family on terminated tab
      #Then A new instance of the census family should be created
        #And I should see the census family is successfully rehired message
      #When I go to the benefits tab I should see plan year information
        #And I should see a button to create new plan year
        #And I should be able to add information about plan year, benefits and relationship benefits
        #And I should see a success message after clicking on create plan year button


    @wip
    Scenario: Employer Representative provides a valid FEIN
      Given I complete the Employer initial form with a valid FEIN
      When I submit the form
      Then My form information is saved to the database
        And My FEIN is compared against the list of HBX-registered FEINs
      When My FEIN match succeeds
      Then My record is updated to include Employer Representative Role
        And My Employer's record is created
        And My Employer Role is set as the Employer administrator
        And My Employer's FEIN is linked to my Employer Reprsentative Role
        And I see my Employer's landing page
    @wip
    Scenario: Employer Representative  provides an unrecognized FEIN 
      Given I complete the Employer initial form with an invalid FEIN
      When I submit the form
      Then My form information is saved to the database
        And the supplied FEIN is compared against the list of registered FEINs
      When The FEIN match fails
      Then I see a message explaining the error and instructing me to either: correct the FEIN and resubmit, or contact reprentatives at the HBX

