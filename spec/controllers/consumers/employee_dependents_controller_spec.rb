require 'rails_helper'

RSpec.describe Consumer::EmployeeDependentsController do
  let(:user) { instance_double("User", :primary_family => family, :person => person) }
  let(:family) { double }
  let(:person) { double }

  describe "GET index" do

    before(:each) do
      sign_in(user)
      get :index
    end

    it "renders the 'index' template" do
      expect(response).to have_http_status(:success)
      expect(response).to render_template("index")
    end

    it "assigns the person" do
      expect(assigns(:person)).to eq person
    end

    it "assigns the family" do
      expect(assigns(:family)).to eq family
    end
  end

  describe "GET new" do
    let(:family_id) { "addbedddedtotallyafamiyid" }
    let(:dependent) { double }

    before(:each) do
      sign_in(user)
      allow(Forms::EmployeeDependent).to receive(:new).with({:family_id => family_id}).and_return(dependent)
      get :new, :family_id => family_id
    end

    it "renders the 'new' template" do
      expect(response).to have_http_status(:success)
      expect(response).to render_template("new")
    end

    it "assigns the dependent" do
      expect(assigns(:dependent)).to eq dependent
    end
  end

  describe "POST create" do
    let(:dependent_properties) { { :family_id => "saldjfalkdjf"} }
    let(:dependent) { double }
    let(:save_result) { false }

    before :each do
      sign_in(user)
      allow(Forms::EmployeeDependent).to receive(:new).with(dependent_properties).and_return(dependent)
      allow(dependent).to receive(:save).and_return(save_result)
      post :create, :dependent => dependent_properties
    end

    describe "with an invalid dependent" do
      it "should assign the dependent" do
        expect(assigns(:dependent)).to eq dependent
      end

      it "should render the new template" do
        expect(response).to have_http_status(:success)
        expect(response).to render_template("new")
      end
    end

    describe "with a valid dependent" do
      let(:save_result) { true }

      it "should assign the dependent" do
        expect(assigns(:dependent)).to eq dependent
      end

      it "should render the show template" do
        expect(response).to have_http_status(:success)
        expect(response).to render_template("show")
      end
    end

  end

  describe "DELETE destroy" do
    let(:dependent) { double }
    let(:dependent_id) { "234dlfjadsklfj" }

    before :each do
      sign_in(user)
      allow(Forms::EmployeeDependent).to receive(:find).with(dependent_id).and_return(dependent)
    end

    it "should destroy the dependent" do
      expect(dependent).to receive(:destroy!)
      delete :destroy, :id => dependent_id
    end

    it "should render the index template" do
      allow(dependent).to receive(:destroy!)
      delete :destroy, :id => dependent_id
      expect(response).to have_http_status(:success)
      expect(response).to render_template("index")
    end
  end

  describe "GET edit" do
    let(:dependent) { double }
    let(:dependent_id) { "234dlfjadsklfj" }

    before :each do
      sign_in(user)
      allow(Forms::EmployeeDependent).to receive(:find).with(dependent_id).and_return(dependent)
      get :edit, :id => dependent_id
    end

    it "should assign the dependent" do
      expect(assigns(:dependent)).to eq dependent
    end

    it "should render the edit template" do
      expect(response).to have_http_status(:success)
      expect(response).to render_template("edit")
    end
  end

  describe "PUT update" do
    let(:dependent) { double }
    let(:dependent_id) { "234dlfjadsklfj" }
    let(:dependent_properties) { { "first_name" => "lkjdfkajdf" } }
    let(:update_result) { false }

    before(:each) do
      sign_in(user)
      allow(Forms::EmployeeDependent).to receive(:find).with(dependent_id).and_return(dependent)
      allow(dependent).to receive(:update_attributes).with(dependent_properties).and_return(update_result)
      put :update, :id => dependent_id, :dependent => dependent_properties
    end

    describe "with an invalid dependent" do
      it "should render the edit template" do
        expect(response).to have_http_status(:success)
        expect(response).to render_template("edit")
      end
    end

    describe "with a valid dependent" do
      let(:update_result) { true }
      it "should render the show template" do
        expect(response).to have_http_status(:success)
        expect(response).to render_template("show")
      end
    end

  end

  describe "GET group_selection" do
    before(:each) do
      sign_in(user)
      get :group_selection
    end

    it "should render the group_selection template" do
      expect(response).to have_http_status(:success)
      expect(response).to render_template("group_selection")
    end
  end
end
