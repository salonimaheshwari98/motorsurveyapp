# Motor Insurance Survey App - Complete Guide

## 🚀 Project Overview

A production-ready Motor Insurance Survey Inspection App with **offline-first mobile** architecture and **FastAPI backend** for insurers to automate survey processes.

---

## 📱 Accessing the Application

### **Mobile App (Flutter)**
- **URL**: http://127.0.0.1:8080 (automatically opened in Browser)
- **Status**: ✅ Running on Chrome

### **Backend API (FastAPI)**
- **URL**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs
- **Status**: ✅ Running

---

## 🔐 Login Credentials

Use any email and password to login (demo mode):
```
Email: test@example.com
Password: password123
```

---

## 📋 App Workflow & Features

### **1. Login Screen**
- Professional Material Design login form
- Email & password authentication
- Test credentials work in demo mode

### **2. Dashboard**
After login, you'll see:
- **Statistics Cards** showing total claims, pending, completed
- **Recent Claims List** with claim numbers and vehicle info
- **Quick Actions** to create new claims
- **Logout** option

### **3. Create New Claim**
Click the **+ FAB button** to create a claim with:
- Claim Number
- Policy Number
- Insurer Details
- Vehicle Information (Model, Number, Year)
- Accident Date & Location
- Insured Person Details

### **4. Claim Details View**
Click on any claim to access the **Survey Workflow**:

**Steps:**
1. **Upload Estimate** - Upload garage estimate (PDF/Image)
2. **Extract Parts** - OCR extracts parts from estimate
3. **Edit Parts** - Interactive table with:
   - Dynamic depreciation calculations based on vehicle age
   - Material type selection (Metal, Plastic, Glass, etc.)
   - Automatic approved amount calculation
   - Accept/Reject checkboxes
   - Real-time summary of total cost vs approved amount

4. **Inspection Photos** - Capture guided photos:
   - Front View, Rear View, Left/Right Side
   - Odometer, Chassis, Damage Photos
   - GPS location & timestamp tracking

5. **Add Remarks** - Surveyor assessment:
   - Detailed inspection notes
   - Liability slider (0-100%)
   - Repair recommendations
   - Voice-to-text options

6. **Generate Report** - Auto PDF with tables, photos, and findings

---

## 🛠️ Tech Stack

### **Frontend (Mobile)**
- **Framework**: Flutter 3.x
- **State Management**: Riverpod 2.x
- **Local Database**: SQLite with offline sync
- **Plugins**:
  - Camera - Photo capture
  - Geolocator - GPS location
  - Google ML Kit - OCR parsing
  - HTTP - API communication

### **Backend (API)**
- **Framework**: FastAPI (async Python)
- **Database**: PostgreSQL + SQLAlchemy ORM
- **Authentication**: JWT tokens
- **File Storage**: Firebase Storage ready
- **PDF Generation**: ReportLab

### **Database**
PostgreSQL tables:
- `users` - Surveyor accounts
- `claims` - Insurance claims
- `parts` - Estimate parts with depreciation
- `photos` - Inspection photos
- `documents` - Supporting documents
- `assessment` - Surveyor assessment

---

## 🔄 Offline-First Sync

**Mobile App:**
- All data stored locally in SQLite
- Records marked `sync_status = pending` when offline
- Auto-syncs to backend when internet available
- No data loss during inspections

**Sync Service:**
- Monitors connectivity
- Batch uploads on reconnect
- Updates `sync_status = synced`

---

## 📊 Key Features

### **Depreciation Engine**
Automatic calculation based on material type:
- **Metal**: 0% (0-6m) → 50% (>10y)
- **Plastic/Rubber/Battery/Tyre**: 50%
- **Glass**: 0%
- **Labour/Paint**: 0%

### **OCR Extract**
Parses estimate lines into structured parts:
```
Input: "Front Bumper 1 4500 4500"
Output: Part(name="Front Bumper", qty=1, rate=4500, amount=4500)
```

### **Editable Parts Table**
- Add/Edit/Delete parts
- Real-time depreciation calculation
- Approve/Reject individual parts
- Summary totals

### **Guided Inspection**
- Sequential photo checklist
- GPS location captured
- Timestamp watermarks
- Auto-upload to Firebase Storage

---

## 🌐 API Endpoints

```
POST   /auth/login                    # User authentication
GET    /claims/list                   # List all claims
POST   /claims/create                 # Create new claim
GET    /claims/{id}                   # Get claim details
POST   /estimate/upload               # Upload estimate
POST   /estimate/parts/update         # Update parts
POST   /photos/upload                 # Upload inspection photos
POST   /reports/generate              # Generate PDF report
```

---

## ✅ Local Development

### **Start Backend**
```bash
cd backend
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### **Start Frontend**
```bash
flutter run -d chrome
```

### **Database Setup**
```bash
# Update DATABASE_URL in backend/database/session.py
# Run migrations
python -m alembic upgrade head
```

---

## 📦 Installation

### **Flutter Dependencies** ✅
```
flutter_riverpod: 2.3.6
camera: 0.10.5
geolocator: 9.0.2
google_ml_kit: 0.16.0
sqflite: 2.2.8
http: 0.13.5
```

### **Python Dependencies** ✅
```
fastapi==0.104.1
uvicorn==0.24.0
sqlalchemy==2.0.23
psycopg2-binary==2.9.9
reportlab==4.0.7
python-jose==3.3.0
passlib==1.7.4
```

---

## 🎯 Next Steps

1. **Connect to PostgreSQL**
   - Update `DATABASE_URL` in `backend/database/session.py`
   - Run migrations

2. **Setup Firebase Storage**
   - Create Firebase project
   - Configure storage bucket
   - Update credentials in flutter_sdk

3. **OCR Integration**
   - Use Google ML Kit text recognition
   - Parse extracted text into parts

4. **PDF Report Generator**
   - Use ReportLab to create professional reports
   - Include claim details, parts table, photos

5. **Deployment**
   - Deploy backend to AWS/GCP
   - Build Flutter APK for Android
   - Build iOS IPA for iPhone

---

## 🔧 Configuration

### **Environment Variables**
Create `.env` file in backend/:
```
DATABASE_URL=postgresql://user:password@localhost/motorsurvey
FIREBASE_KEY=<firebase-service-account-key>
JWT_SECRET=<your-secret-key>
ENVIRONMENT=development
```

### **Firebase Config**
Update `lib/core/firebase_config.dart`:
```dart
const firebaseOptions = FirebaseOptions(
  apiKey: '<API_KEY>',
  appId: '<APP_ID>',
  messagingSenderId: '<SENDER_ID>',
  projectId: '<PROJECT_ID>',
  storageBucket: '<BUCKET>',
);
```

---

## 📱 Screenshots

### Login Screen
- Professional design with car icon
- Email & password fields
- Forgot password link

### Dashboard
- Claim statistics
- Recent claims list
- Status badges
- Create new claim FAB

### Claim Details
- Workflow steps with progress
- Claim information display
- Step navigation

### Parts Editor
- Interactive data table
- Vehicle age slider
- Material type selector
- Real-time depreciation
- Summary calculations

### Inspection
- Guided photo checklist
- GPS location tracking
- Photo preview

### Remarks
- Notes text editor
- Liability slider
- Recommendation field
- Voice-to-text option

---

## 🚀 Performance

- **Offline-first**: Works without internet during inspection
- **Fast OCR**: Real-time parts extraction
- **Efficient Sync**: Batch uploads when online
- **Optimized DB**: SQLite for mobile, PostgreSQL for backend
- **Auto-calculations**: Instant depreciation updates

---

## 📄 License

Proprietary - Insurance Survey Platform

---

## 👨‍💻 Support

For issues or questions, contact the development team.

**Happy Surveying!** 🚗📋
