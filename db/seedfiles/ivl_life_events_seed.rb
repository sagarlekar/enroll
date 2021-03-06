
LifeEvent.create!(
  title: "Open enrollment",
  description: "Consumer is enrolling during an annual open enrollment period",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "Initial Enrollment",
  coverage_effective_on_kind: :date_range,
  coverage_offset_kind: 15,
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: ["11-01-2015".."01-31-2016"],
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "60 days before loss of MEC",
  coverage_effective_date: "If before loss of coverage: First day of the month after MEC will end. If after loss of MEC: First day of the month following plan selection (not following 15th of month rule)")

LifeEvent.create!(
  title: "Loss of other health coverage",
  description: "Consumer lost other minimum essential coverage involuntarily",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: :first_of_month,
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60, # "60 days before loss of coverage and 60 days after",
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "60 days before loss of MEC",
  coverage_effective_date: "If before loss of coverage: First day of the month after MEC will end. If after loss of MEC: First day of the month following plan selection (not following 15th of month rule)")

LifeEvent.create!(
  title: "Mid-Month Loss of MEC",
  description: "Consumer losing MEC on a date other than the last day of a month",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  coverage_effective_on_kind: "",
  coverage_offset_kind: :first_of_month,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60, # "60 days before the day of the loss of coverage",
  event: "coverage end date"
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "60 days before coverage ends",
  coverage_effective_date: "The effective date is the first day of the month in which the prior coverage is terminating (following plan selection).")

LifeEvent.create!(
  title: "Adding a person to household",
  title: "I had a baby",
  description: "Household adds a member due to marriage, birth, adoption, placement for adoption, or placement in foster care",
  coverage_effective_on_kind: "",
  coverage_offset_kind: :date_of_event,
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  coverage_effective_date: "Date of birth, adoption, placement for adoption, placement in foster care, or marriage.  For marriage: First day of the month following plan selection (not following 15th of month rule); this applies to all members of household")

LifeEvent.create!(
  title: "Adding a person to household",
  title: "I adopted a child",
  description: "Household adds a member due to marriage, birth, adoption, placement for adoption, or placement in foster care",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: :date_of_event,
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  coverage_effective_date: "Date of birth, adoption, placement for adoption, placement in foster care, or marriage.  For marriage: First day of the month following plan selection (not following 15th of month rule); this applies to all members of household")

LifeEvent.create!(
  title: "Adding a person to household",
  title: "I married",
  description: "Household adds a member due to marriage, birth, adoption, placement for adoption, or placement in foster care",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: :date_of_event,
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  coverage_effective_date: "Date of birth, adoption, placement for adoption, placement in foster care, or marriage.  For marriage: First day of the month following plan selection (not following 15th of month rule); this applies to all members of household")

LifeEvent.create!(
  title: "Moving into the District of Columbia",
  description: "Consumer or a member of the consumer’s tax household moves to the District",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: :date_of_event,
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "Date of move    ",
  coverage_effective_date: "Regular effective date")


LifeEvent.create!(
  title: "Change in APTC/CSR",
  description: "Consumer has a change in circumstances that makes him or her newly eligible or ineligible for APTC changes eligibility for CSR. Only applies to those already enrolled in a QHP.",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: "",
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "Date of eligibility redetermination (NOTE: this is not necessarily the date the customer reported the change)",
  coverage_effective_date: "Regular effective date")

LifeEvent.create!(
  title: "Change in immigration status",
  description: "Consumer gains status a citizen, national, or lawfully present immigrant",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: "",
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "Date change was verified (NOTE: this is not necessarily the date the customer reported the change)",
  coverage_effective_date: "Regular effective date")

LifeEvent.create!(
  title: "Being Native American",
  description: "American Indians/Alaskan Natives can enroll in a plan at any time",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: "",
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 30,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "Date approved by HBX",    
  coverage_effective_date: "Regular effective date")

LifeEvent.create!(
  title: "Erroneous enrollment, HBX/HHS",
  description: "Enrollment or non-enrollment in QHP unintentional, inadvertent, or erroneous and is result of error, misrepresentation, or inaction by an agent of HBX or HHS",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: "",
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "Date approved by HBX",    
  coverage_effective_date: "Regular effective date")

LifeEvent.create!(
  title: "Erroneous enrollment, QHP issuer",
  description: "Enrollment or non-enrollment in QHP unintentional, inadvertent, or erroneous and is result of error, misrepresentation, or inaction by an agent of a QHP issuer (as determined by DISB)",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: "",
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "Date approved by HBX",    
  coverage_effective_date: "Regular effective date")

LifeEvent.create!(
  title: "Misconduct of non-Exchange entity providing enrollment assistance",
  description: "Consumer was not enrolled, was enrolled in the wrong plan, or was eligible for but did not receive APTC or CSR due to misconduct by a non-Exchange entity providing enrollment assistance",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: "",
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "Date approved by HBX",       
  coverage_effective_date: "Regular effective date")

LifeEvent.create!(
  title: "QHP violated its contract",
  description: "The QHP the person enrolled in substantially violated a material provision of its contract with the consumer",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: "",
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "Date approved by HBX",       
  coverage_effective_date: "Regular effective date")

LifeEvent.create!(
  title: "Found ineligible for Medicaid after open enrollment ended",
  description: "Consumer had pending Medicaid eligibility at the end of open enrollment, but was found ineligible after open enrollment.",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: "",
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "Date consumer received notice of Medicaid ineligibility",
  coverage_effective_date: "Regular effective date")

LifeEvent.create!(
  title: "Consumer’s employer applied to SHOP exchange but was found ineligible",
  description: "Consumer did not enroll in a QHP because consumer’s employer was applying to provide coverage through SHOP during open enrollment. Consumer’s employer was found ineligible to participate in SHOP after the end of open enrollment",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: "",
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "Date consumer received notice of SHOP ineligibility    ",
  coverage_effective_date: "Regular effective date")

LifeEvent.create!(
  title: "Exceptional circumstance due to a natural disaster",
  description: "(HBX)   A natural disaster prevented consumer from enrolling during open enrollment or an SEP",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: "",
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "Day of disaster (or last day of multi-day disaster)",
  coverage_effective_date: "Regular effective date")

LifeEvent.create!(
  title: "Exceptional circumstance due to medical emergency",
  description: "A serious medical condition prevented consumer from enrolling during open enrollment or an SEP",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: "",
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "Date approved by HBX",       
  coverage_effective_date: "Regular effective date")

LifeEvent.create!(
  title: "Exceptional circumstance due to system outages around plan selection deadlines",
  description: "DC Health Link outage or outage of federal or local data sources around the plan selection deadline prevented consumer from enrolling during open enrollment or an SEP",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: "",
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "Day of outage",
  coverage_effective_date: "Regular effective date")

LifeEvent.create!(
  title: "Exceptional circumstances due to being a victim of domestic abuse",
  description: "A person is leaving an abusive spouse or domestic partner",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: "",
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "Date person leaves spouse or domestic partner",
  coverage_effective_date: "Regular effective date")

LifeEvent.create!(
  title: "Exceptional circumstances due to loss of eligibility for hardship exemption",
  description: "Consumer who received a certificate of exemption from the individual mandate for a month or months during the coverage year who loses eligibility for the exemption.",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: "",
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 30,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "30 days prior to date of ineligibility for exemption",
  coverage_effective_date: "Regular effective date")

LifeEvent.create!(
  title: "Exceptional circumstance for those beginning or ending AmeriCorps State and National, VISTA, or NCCC service",
  description: "An individual is a member of AmeriCorps State and National, VISTA, or NCCC.",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: "",
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "Date person begins or ends service in one of the three programs",
  coverage_effective_date: "Regular effective date")

LifeEvent.create!(
  title: "Divorce/Domestic Partnership Termination",
  description: "Consumer divorces or legally separates",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: :first_of_month,
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "Date of divorce, legal separation, partnership termination",
  coverage_effective_date: "First day of the month following plan selection (not following 15th of month rule); this applies to all members of household")

LifeEvent.create!(
  title: "Entering a domestic partnership",
  description: "Entering a domestic partnership as permitted or recognized by the District of Columbia",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: :first_of_month,
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "Date partnership entered into",
  coverage_effective_date: "First day of the month following plan selection (not following 15th of month rule); this applies to all members of household")

LifeEvent.create!(
  title: "Medical coverage order (mandate)",
  description: "A person is required by a court (through a medical insurance coverage order) for themselves or someone else",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: "",
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: "60 days ",
  is_self_attested: true,
  event_kind: "date of court order",
  start_of_sep: "Date of the court order",
  coverage_effective_date: "Regular effective date"))

LifeEvent.create!(
  title: "Dependent loss of ESI due to employee gaining Medicare",
  description: "A dependent is losing access to ESI coverage because the employee is enrolling in Medicare",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: :first_of_month,
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 60,
  is_self_attested: true,
  event_kind: "coverage end date",
  start_of_sep: "60 days before loss of MEC",
  coverage_effective_date: "If before loss of coverage: First day of the month after MEC will end. If after loss of MEC: First day of the month following plan selection (not following 15th of month rule)")

LifeEvent.create!(
  title: "Employer failure to pay COBRA premiums on time",
  description: "Consumer loses access to COBRA because the employer responsible for submitting premiums fails to submit them on time",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: "",
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "Based on circumstances as determined by HBX Date of loss of coverage",
  coverage_effective_date: "As determined by HBX, with the intent of preventing gaps in health coverage")

LifeEvent.create!(
  title: "Uninsured District Residents Facing IRS Tax Penalties",
  description: "Consumer who may be subject to a federal tax penalty because they did not have health insurance, who when preparing the 2014 federal taxes the taxpayer first became aware of the tax penalty after open enrollment ended on February 15, 2015, or filed their 2014 federal tax return, and the taxpayer paid a tax penalty to the IRS for not having health coverage in 2014.",
  kind: :add_member,
  market_kind: :individual,
  edi_reason: "",
  coverage_effective_on_kind: "",
  coverage_offset_kind: :date_range,
  pre_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: 0,
  post_event_pre_event_sep_in_days: 0,
  post_event_sep_in_days: ["03-15-2015".."04-30-2015"],
  is_self_attested: true,
  event_kind: "",
  start_of_sep: "Date reported",   
  coverage_effective_date: "Regular effective date")
