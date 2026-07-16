
MOD-03  Policy Details (7-Step Wizard)   •   Admin Portal 
Full lifecycle management of group insurance policies. A 7-step progressive wizard. The most complex module in the platform. All steps are accessible from the All Policies list view.

All Policies List View
Displays all policies across all corporates. Filter tabs: ALL / ACTIVE / EXPIRED / DRAFT. Export button. Columns: SI NO, Policy Number (hyperlink to 7-step detail), Corporate Name, Policy Status (badge: Active=green, Draft=amber, "Policy Not Yet Issued"=amber), Line of Business, Policy Type, Insurer, TPA, Family Definition, Policy Start Date, Policy End Date, Created At.
195 total entries in test data. 20 pages at 10/page.


Add Policy
Step 1 — Policy Details
Field Name	Type	Req.	Valid Values / Constraints	DB Column / Notes
Corporate Name	Dropdown	Yes	Select from master_corporates (active). Auto-locked after policy creation.	master_add_policies.ref_corporate_id
Line of Business	Dropdown	Yes	Health (display_id=1), Life (display_id=2), Others (display_id=3). Stored as varchar.	master_add_policies.line_of_business
Policy Type	Dropdown	Yes	GMC, GPA, Parent Policy, Top Up Policy, GTL, Marine, Fire, Office Package, Motor Insurance, Travel Insurance, Property Insurance, Commercial Insurance, Asset Insurance, Pet Insurance, Bite-Sized Insurance, Workmen Compensation. Stored as varchar with display_id.	master_add_policies.policy_type → md_policy_types.policy_type_value
Select Insurer	Dropdown	Yes	Searchable. Minimum 3 characters to search. Full insurer master list. Includes Acko, Aditya Birla, Apollo Munich, Bajaj Allianz, Bharti AXA, Chola, Cigna TTK, and 30+ others.	master_add_policies.select_insurer (varchar, stores insurer name)
Select TPA	Dropdown	No	Searchable. 3-char minimum. 27+ TPAs including Medi Assist, MDIndia, Paramount, Heritage, Family Health Plan, Raksha, Vidal, Volo, Medave, and others. Can be blank for non-health policies.	master_add_policies.select_tpa (varchar)
Do you have policy number?	Radio	Yes	Yes / No. If No, policy_number stored as NULL and status = 2 (Draft). Policy Number field appears only when Yes is selected.	Controls master_add_policies.policy_number
Policy Number	Text	Conditional	Required if "Yes" above. Free text. Max 50 chars.	master_add_policies.policy_number
Policy Start Date	Date	No	DD-MM-YYYY picker	master_add_policies.policy_start_date
Policy End Date	Date	No	DD-MM-YYYY picker. Should be after start date.	master_add_policies.policy_end_date
Family Definition	Dropdown	No	Self + Spouse + 2 Children (most common), Self, Self + Spouse, and other combinations	master_add_policies.family_definition (varchar)
Claim submission visibility	Radio	No	On / Off. Controls whether employees can submit claims for this policy from the employee portal.	master_add_policies.claim_submission_visibility (0/1)
Intimate claim visibility	Dropdown	No	Both / HR Only / Employee Only. Controls who can see the claim intimation UI.	master_add_policies.intimate_claim_visibility (varchar: 'Both','HR','Employee')

Step 2 — Policy Features (Benefit Parameter Configuration)
This step defines the health insurance benefit parameters for the policy. An unlimited number of named Policy Feature Identifiers (benefit tiers) can be created — each tier has its own full set of benefit parameters. Click "Add New" or "Add New (blank)" to create a tier. Click "Edit" to modify. Click "Clone" to duplicate an existing tier.
The benefit parameter form is very long (40+ fields). All fields have an "All" filter dropdown that applies across Feature Identifiers. Custom fields can also be added via the "Add New Field" modal (Field Name, Field Placeholder, Field Type, Mandatory Yes/No). Custom fields are stored in master_policy_feature_template_fields and their values in mapping_policy_feature_templates_corporates_policies.

Field Name	Type	Values / Notes	DB Reference
Feature Identifier	Text	Name of the benefit tier (e.g., "Good Will", "Executive", "Staff")	master_policyfeature_identifiers.identifier_name
Room Rent Limit	Number + Dropdown	Amount in INR. Dropdown: All / specific value.	mapping_policy_feature_templates. field: room_rent_limit
ICU Limit	Number + Dropdown	Amount in INR.	field: icu_limit
Proportionate deduction on exceeding room rent	Number + Dropdown	Amount or percentage.	field: proportionate_deduction
Existing Disease Waiting Period	Text + Dropdown	Free text description (e.g., "2 years", "30 days").	field: existing_disease_waiting_period
Ailment wise waiting period	Text + Dropdown	Free text.	field: ailment_wise_waiting_period
Pre & post natal Expenses	Number + Dropdown	Amount in INR.	field: pre_post_natal_expenses
Ailment wise capping	Number + Dropdown	Amount in INR.	field: ailment_wise_capping
Internal congenital disease	Number + Dropdown	Amount in INR.	field: internal_congenital_disease
External congenital disease	Number + Dropdown	Amount in INR.	field: external_congenital_disease
Pandemic	Number + Dropdown	Amount in INR.	field: pandemic
Pre-Hospitalization	Number + Dropdown	Amount in INR or days.	field: pre_hospitalization
Post Hospitalization	Number + Dropdown	Amount in INR or days.	field: post_hospitalization
Restore Benefit	Number + Dropdown	Amount in INR.	field: restore_benefit
Copay	Radio + Dropdown	Yes / No. If Yes, Copay Deduction % field appears.	field: copay (Yes/No), copay_deduction_percentage
Copay Deduction in %	Number	Appears when Copay = Yes. Percentage value.	field: copay_deduction_percentage
Remark	Rich Text	HTML-capable remarks field. Rich text editor.	field: remark (stored as HTML)
No Claim Bonus	Radio	Yes / No	field: no_claim_bonus
% Increase in Sum Insured	Number + Dropdown	Percentage. Appears when NCB = Yes.	field: ncb_percentage_increase
Discount Premium	Number + Dropdown	Amount in INR.	field: discount_premium
Organ Donor	Radio + Number	Yes / No. If Yes, Organ Donor Value field appears.	field: organ_donor, organ_donor_value
OPD Cover	Radio + Number	Yes / No. If Yes, OPD Amount Payable appears.	field: opd_cover, opd_amount_payable
Maternity Cover	Radio	Yes / No. If Yes: Maternity Waiting Period, Normal Delivery Sum Insured, C-Sec Sum Insured appear.	field: maternity_cover
Maternity Waiting Period	Text + Dropdown	Free text.	field: maternity_waiting_period
Normal delivery sum Insured	Number + Dropdown	Amount in INR.	field: normal_delivery_sum_insured
C Sec — sum Insured	Number + Dropdown	Amount in INR.	field: c_sec_sum_insured
Baby Vaccination	Radio + Number	Yes / No. If Yes, Baby Vaccination Amount Payable appears.	field: baby_vaccination, baby_vaccination_amount
Newborn baby cover	Radio	Yes / No	field: newborn_baby_cover
Health Checkup	Radio + Number	Yes / No. If Yes: Initial Waiting Period + Health Checkup Amount Payable appear.	field: health_checkup
Emergency Ambulance	Radio + Number	Yes / No. Amount Payable appears if Yes.	field: emergency_ambulance, emergency_ambulance_amount
Domiciliary Hospitalization	Radio + Number	Yes / No. Domiciliary Hospitalization Value appears if Yes.	field: domiciliary_hospitalization, domiciliary_value
Ayurveda/Homeopathy	Radio + Number	Yes / No. Amount Payable appears if Yes.	field: ayurveda_homeopathy, ayurveda_amount
Eye Cover	Radio + Number	Yes / No. Amount Payable appears if Yes.	field: eye_cover, eye_cover_amount
Dental Cover	Radio + Number	Yes / No. Amount Payable appears if Yes.	field: dental_cover, dental_cover_amount
Critical Illness Benefit	Radio + Number	Yes / No. Amount Payable appears if Yes.	field: critical_illness_benefit, critical_illness_amount
Worldwide Emergency Cover	Radio + Number + Number	Yes / No. Amount Payable + Amount Deductible appear if Yes.	field: worldwide_emergency_cover, worldwide_amount, amount_deductible
Amount Deductible	Number + Dropdown	Amount in INR.	field: amount_deductible
Add Remarks	Rich Text	Full HTML rich text editor for additional notes.	field: add_remarks (stored as HTML)

Add New Field (Custom Fields)
The Policy Features step includes an "Add New Field" modal allowing the creation of custom benefit parameters not in the standard list. Custom fields have: Field Name (label), Field Placeholder, Field Type (Text/Dropdown/Date/Checkbox etc.), Mandatory (Yes/No). Custom field definitions are stored in master_policy_feature_template_fields. Their values per policy per feature identifier are stored in mapping_policy_feature_templates_corporates_policies. Custom fields appear in the Corporate Portal Policy Features view and in the Employee Portal if employee_details_editable = true.

Step 3 — Sum Insured
Links sum insured amounts to Policy Feature Identifiers. Multiple rows supported. Each row: Sum Insured (number, required) + Policy Feature Identifier (dropdown from Step 2 identifiers, required). Add More / Delete row actions.
Field Name	Type	Req.	Valid Values / Constraints	DB Column / Notes
Sum Insured	Number	Yes	Amount in INR. E.g., 300000, 500000, 1000000.	master_sum_insureds.sum_insured_amount
Policy Feature Identifier	Dropdown	Yes	Select from identifiers created in Step 2.	master_sum_insureds.ref_policyidentifier_id → master_policyfeature_identifiers

Step 4 — Data Upload
Manages three types of data files linked to the policy. Includes upload form and upload history log.
Field Name	Type	Req.	Valid Values / Constraints	DB Column / Notes
			
				
Select Data Type	Dropdown	Yes (for upload)	Endorsement Data, Claims Dump, Ecards, Inception Data.	master_policy_data_uploads.data_type (varchar)
Remark	Text	No	Free text note for this upload.	master_policy_data_uploads.remark
Policy Data Upload	File	Yes (for upload)	CSV or Excel file. Size: no explicit limit on this endpoint (per dev team).	master_policy_data_uploads.policy_data_upload (S3 path)
Upload history table columns: #, File Name (clickable download link), Data Type, Remark, Status (Success badge / View Detail button for errors), Created At. View Detail opens the upload error report.

Data Types Explained
Data Type	What It Contains	Processing	Error Table
Inception Data	Initial employee roster at policy start. Columns: employee_code, employee_name, gender, relationship, dob, age, mobile_number, email, sum_insured, doj, endorsement_number, endorsement_date, endorsement_type, dol, member_card_number, designation.	InceptionDataImport class. SkipsOnFailure = YES. Valid rows inserted to master_inception_data_uploads.	master_dataupload_error
Endorsement Data	Employee additions, deletions, and changes mid-policy. Same column format as Inception Data plus endorsement_type (addition/deletion/correction).	EndorsementDataImport class. SkipsOnFailure = YES. Valid rows to master_endorsement_data_uploads.	master_dataupload_error
Claims Dump	TPA claim settlement data imported from insurer. 38 columns including TPA claim no, status, amounts, ICD codes, hospital details.	TotalClaimReportImport class. SkipsOnFailure = NO. updateOrCreate on tpa_claim_no. Updates master_total_claim_reports.	None — no row-level error logging for this import
Ecards	PDF e-card files uploaded by admin/broker as received from insurer. NOT system-generated.	EcardsDataImport. Valid records stored in master_ecards_data_uploads with S3 path.	master_ecards_data_upload_errors

Step 5 — Escalation Matrix (EM)
Assigns escalation contacts to this specific policy. Shows list of assigned contacts and allows adding new ones. This is the policy-level escalation matrix (master_policy_escalation_matrices), not the global matrix (master_escalation_matrices).
Field Name	Type	Req.	Valid Values / Constraints	DB Column / Notes
Level	Dropdown	Yes	Level 1 (Immediate), Level 2 (Manager), Level 3 (Director). Stored as level string and ref_escalation_matrices_level_id.	master_policy_escalation_matrices.level, ref_escalation_matrices_level_id
Select user	Dropdown	Yes	Select from master_escalation_matrices (global escalation contacts list). Returns ref_master_users_id and ref_user_fullname.	master_policy_escalation_matrices.ref_master_users_id, ref_user_fullname
List view columns: #, Level, Full Name, Phone No, Mobile No, Email, Address, Type (Broker/HR/other), Status (Active badge), Created At, Actions (Delete).

Step 6 — Documents
Attaches documents to the policy. Two types: Service Documents (visible to HR and Employee) and Policy Documents (visible to HR only).
Field Name	Type	Req.	Valid Values / Constraints	DB Column / Notes
Document Type	Dropdown	Yes	Service Document — helps with claim procedure (visible to HR + Employee). Policy Documents (Policy Copies) — visible to HR only. Stored as ref_document_type_id (1 = Service, 2 = Policy Document).	master_policy_documents.ref_document_type_id, document_type
Document Name	Dropdown + Text	Yes	Searchable combo. Pre-defined options + free text entry. E.g., "Claim form".	master_policy_documents.ref_document_name_id, document_name
Note	Text	No	Optional annotation for the document.	master_policy_documents.note
Attach Documents	File upload	Yes	PDF only. Stored on S3. Returns download URL.	master_policy_documents.document_file (S3 path), original_file_name
List view columns: S.No, Document Type, Document Name, Attachment (PDF download link), Note, Action (delete).

Step 7 — CD Statements
Shows the credit/deposit account ledger for this policy. Read-only in this wizard step. Transactions are added via the CD Statements module (MOD-04). Columns: #, Policy Number, Particular (transaction description), Debit Amount (DR), Credit Amount (CR), Policy Endorsement No, Endorsement Issued Date. Export CSV and Add CD Statement buttons available.

Business Rules
•	A policy can have multiple Policy Feature Identifiers (benefit tiers). Each tier has its own full set of 40+ benefit parameters. Employees are assigned to one or more tiers.
•	Policy status is automatically set to 2 (Draft) when "Do you have policy number = No" is selected. Status = 1 (Live) only when a policy number is assigned.
•	Financial year (ref_fy_year_id) is assigned at policy creation and is immutable. All child records inherit this value.
•	A policy can span two calendar years. It is still assigned to exactly one financial year (the FY in which the policy was created or renewed).
•	Data uploads are synchronous — the user waits for processing to complete. Partial success is supported: valid rows are inserted, invalid rows are logged to error tables. The user can view errors via the "View Detail" link in the upload log.
•	Ecards are manually uploaded PDF files received from the insurer/corporate. They are NOT generated by the system. Download via GET /api/v2/get_ecards/{id}/{policyId} from the Employee Portal.
•	Policy escalation matrix entries (Step 5) override the global escalation matrix for this specific policy. Both can exist simultaneously.
•	All 7 steps must be completed for the policy to be considered fully configured. Step completion is tracked in mapping_policy_completions (policy_id + section_id).

API Endpoints (Policy Core)
Method	Endpoint	Description	Key Parameters / Notes
GET	/api/get_policy_data/{id?}/{fyId}	List all policies	id=optional corporate filter, fyId=financial year, 0=all years
GET	/api/get_view_policy_data/{id}	Get single policy detail	All 7 sections of data for one policy. Used to populate the wizard for editing.
POST	/api/create_add_policy	Create new policy (Step 1)	Returns policy_id for subsequent steps
PUT	/api/update_policy_status/{id}	Update policy status	Used to toggle Live/Draft
POST	/api/save_policy_feature	Save Policy Features (Step 2)	Saves all benefit parameter values for a feature identifier
PUT	/api/update_policyfeature/{id}	Update existing Policy Feature	Edit an existing feature identifier's parameters
GET	/api/edit_policyfeature/{id}	Get feature data for editing	Retrieves all stored values for a feature identifier
POST	/api/create_policy_feature_template	Create new field definition	For custom fields added via Add New Field modal
GET	/api/get_default_tempalte/{policytypeId}	Get default template for policy type	Pre-populates Step 2 with standard benefit fields for the selected policy type
POST	/api/create_sum_insured	Save Sum Insured entries (Step 3)	Accepts array of sum_insured + ref_feature_identifier_id pairs
DELETE	/api/delete_sum_insured/{suminsuredId}	Remove Sum Insured row	
POST	/api/policy_data_upload	Upload data file (Step 4)	Multipart form data. data_type + file + remark + ref_policy_id
GET	/api/get_policy_data_uploads_data/{policyId}	Get upload history for a policy	Returns array of upload log entries
GET	/api/policy_dataupload_error/{id}	Get upload error details	Shows row-level errors for a failed/partial upload
POST	/api/policy_create_EM	Add escalation matrix to policy (Step 5)	
DELETE	/api/delete_EM_user/{EMuserId}	Remove EM user from policy	
POST	/api/policy_document_upload	Upload policy document (Step 6)	
GET	/api/get_policy_documents_data/{policyId}	Get documents for a policy	
DELETE	/api/delete_policy_document/{id}	Remove policy document	
GET	/api/get_cd_statement_data/{policyId}	Get CD statement for policy (Step 7)	Read-only in this context
GET	/api/policy_info_meta_data	Get all policy master data	Returns insurers, policy types, TPAs, line of business options for dropdowns
GET	/api/get_policy_tpa	Get TPA list	Populated from md_policy_tpas table
GET	/api/get_policy_no/{id}	Get policy number for a corporate	
GET	/api/v2/get_feature_identifier/{id}	Get feature identifiers for a policy	v2 endpoint used by Corporate Portal

Toggle Visibility Matrix
Function	Vibe Admin	Notes
View All Policies list	ON	
Add Policy (create new)	ON	
Edit Policy (all 7 steps)	ON	
Update Policy Status (Live/Draft)	ON	
Delete Policy	OFF	No delete endpoint found. Soft delete via status change only.
Export Policies list	ON	CSV export via Export button
Step 4: Upload Data Files	ON	
Step 4: Download Sample CSV	ON	
Step 5: Manage Escalation Matrix	ON	
Step 6: Upload Documents	ON	
Step 7: View CD Statements	ON	Read-only view in this wizard step

