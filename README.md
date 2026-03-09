You are a senior full-stack software architect and engineer.

I already have a partially working project for a **Motor Insurance Survey Inspection System** but multiple modules are broken or incomplete.

Your task is to **fix the architecture, complete missing functionality, connect frontend and backend properly, and produce a working prototype**.

The system consists of:

Frontend:
Flutter mobile app

Backend:
Python FastAPI

Database:
PostgreSQL

Storage:
AWS S3

Authentication:
JWT authentication

Report Generation:
LaTeX → PDF

The goal is to automate **motor vehicle insurance survey inspection and report generation**.

---

CRITICAL REQUIREMENT

The frontend must be **fully connected with the backend APIs**.

Ensure:

• proper API endpoints
• request/response models
• error handling
• authentication middleware
• data validation
• async file upload
• AWS S3 storage integration

---

AUTHENTICATION MODULE

Fix the login and signup system.

Requirements:

1. Proper **Login and Signup pages**
2. Email verification required
3. Login must only accept **valid email addresses**
4. Name must NOT be accepted in place of email
5. Implement **Forgot Password workflow**
6. Use JWT authentication
7. Store user details in database

Database table:

users

fields:
id
name
email
password_hash
verified
surveyor_license
created_at

The report must always record the **logged-in surveyor's identity**.

---

DASHBOARD MODULE

After login show a dashboard.

Display:

• Logged in surveyor name
• list of claims

Each claim card should show:

Claim Number
Vehicle Number
Insurer Name (example ICICI Lombard)
Policy Number
Status

Status must become **Finished only after report generation**.

Fix claim creation because currently claim addition does not work.

When adding claim allow:

• upload policy document
• auto extract initial details from policy

Sort recent claims **chronologically**.

---

CLAIM REGISTRATION

Allow uploading documents at claim creation:

Policy
Vehicle Registration (RC)
Driving License
Pollution Certificate
Challan
Aadhar

Store documents in **AWS S3**.

Database table:

claims

fields:

id
claim_number
policy_number
insurer
insured_name
vehicle_number
vehicle_model
manufacture_year
policy_file
status
created_at

---

ESTIMATE UPLOAD

Allow uploading estimate PDF or image.

Must support **reuploading the document**.

Files must be stored in **AWS S3**.

Backend should process file using OCR.

---

ESTIMATE EXTRACTION AND EDITABLE TABLE

Extract estimate data from uploaded PDF.

The uploaded sample estimate contains a table with columns like:

Sr No
Part Number
Part Description
Qty
Rate
Extra Charge
Total Amt Base Price
Discount
Taxable Amt
CGST Rate and Amount
SGST Rate and Amount
Total Amount

This table must be extracted.

Example structure visible in the uploaded estimate pages.  

Create an editable table in frontend with columns:

Se No
Particulars
Qty
Rate
Total Amt (Base Price)
Taxable Amount
CGST Rate
CGST Amount
SGST Rate
SGST Amount
Total Amount
Approve / Reject
Material Type

Material Type options:

Metal
Plastic
Rubber
Glass
Electrical
Labour
Paint

If extraction fails then create **default empty table with these columns** so surveyor can manually enter data.

Make table fully editable.

Add **Save button and ensure it works**.

---

VEHICLE AGE

Vehicle age must be calculated automatically.

Age = current year − manufacture year.

Use either:

manufacture year from claim registration
or vehicle purchase date

---

INSPECTION MODULE

Inspection page must allow:

Option 1:
Capture live photo

Option 2:
Upload existing image

Captured photos must include:

timestamp
GPS location

Add watermark text:

Vehicle Number
Date Time
Location

Fix current issue where location and timestamp are not working.

Store images in AWS S3.

---

REMARKS AND ASSESSMENT

Create a clean remarks screen.

Fields:

Inspection Notes
Liability Assessment
Repair Recommendation

Remove unnecessary options.

Ensure form submission works.

---

REPORT GENERATION

Implement report generation using **LaTeX templates**.

Report should be **3-5 pages formal legal report**.

Sections:

Surveyor Details
Claim Details
Vehicle Details
Inspection Notes
Estimate vs Approved Table
Photographs
Documents

Documents included in report:

Policy
RC
DL
Pollution
Challan
Aadhar

Report must include:

digital signature based on logged-in surveyor credentials.

Output:

PDF file.

---

BACKEND API ENDPOINTS

/auth/signup
/auth/login
/auth/forgot-password

/claims/create
/claims/list
/claims/{id}

/estimate/upload
/estimate/extract

/photos/upload

/remarks/save

/report/generate

---

AWS STORAGE

Implement S3 storage for:

policy files
estimate files
inspection images
documents
generated reports

---

UI IMPROVEMENTS

Make the UI:

responsive
clean
mobile friendly

Use modern Flutter UI components.

---

EXPECTED OUTPUT

Refactor and generate:

1. Fixed Flutter frontend screens
2. Working FastAPI backend
3. PostgreSQL models
4. AWS S3 integration
5. OCR estimate parsing
6. Editable estimate table
7. Inspection photo capture module
8. LaTeX report generator
9. Authentication system
10. API integration between frontend and backend

Ensure the system runs as a **working prototype**.

Explain key code sections.
