class BrokerRole
  include Mongoid::Document
  include Mongoid::Timestamps

  PROVIDER_KINDS = %W[broker assister]

  embedded_in :person

  # Broker National Producer Number (unique identifier)
  field :npn, type: String
  field :broker_agency_id, type: BSON::ObjectId
  field :provider_kind, type: String

  # field :aasm_state, type: String
  # field :aasm_message, type: String
  field :is_active, type: Boolean, default: true

  delegate :hbx_id, :hbx_id=, to: :person, allow_nil: true

  accepts_nested_attributes_for :person

  validates_presence_of :npn, :provider_kind
  validates :npn, uniqueness: true
  validates :provider_kind,
    allow_blank: false,
    inclusion: { in: PROVIDER_KINDS, message: "%{value} is not a valid provider kind" }


  # scope :all_active_brokers, ->{ and({ kind: "broker" }, { is_active: true })}
  # scope :all_active_tpas, ->{ and({ kind: "tpa" }, { is_active: true })}

  # def initialize(attrs = nil, options = nil)
  #   super
  #   # put code here
  # end

  def self.find(broker_role_id)
    Person.where("broker_role._id" => broker_role_id).first.broker_role
  end  

  def self.find_by_npn(npn_value)
    Person.where("broker_role.npn" => npn_value).first.broker_role
  end

  def self.list_brokers(person_list)
    person_list.reduce([]) { |brokers, person| brokers << person.broker_role }
  end

  # TODO; return as chainable Mongoid::Criteria
  def self.all
    # criteria = Mongoid::Criteria.new(Person)
    list_brokers(Person.exists(broker_role: true))
  end

  def self.first
    self.all.first
  end

  def self.last
    self.all.last
  end

  def self.find_by_broker_agency(broker_agency)
    return unless broker_agency.is_a? BrokerAgency
    list_brokers(Person.where("broker_role.broker_agency_id" => broker_agency._id))
  end

  def parent
    # raise "undefined parent: Person" unless self.person?
    self.person
  end

  # belongs_to broker_agency
  def broker_agency=(new_broker_agency)
    if new_broker_agency.nil?
      self.broker_agency_id = nil
    else
      raise ArgumentError.new("expected BrokerAgency class") unless new_broker_agency.is_a? BrokerAgency
      self.broker_agency_id = new_broker_agency._id
    end
    self.broker_agency
  end

  def broker_agency
    BrokerAgency.find(broker_agency_id) if has_broker_agency?
  end

  def has_broker_agency?
    self.broker_agency_id.present?
  end

  def address=(new_address)
    parent.addresses << new_address
  end

  def address
    parent.addresses.detect { |addr| addr.kind == "work" }
  end

  def phone=(new_phone)
    parent.phones << new_phone
  end

  def phone
    parent.phones.detect { |phone| phone.kind == "work" }
  end

  def email=(new_email)
    parent.emails << new_email
  end

  def email
    parent.emails.detect { |email| email.kind == "work" }
  end

  def is_active?
    self.is_active
  end


end