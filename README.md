<div align="center">

<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" />
<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
<img src="https://img.shields.io/badge/PyTorch-EE4C2C?style=for-the-badge&logo=pytorch&logoColor=white" />
<img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" />

# 🔬 Optim — AI-Powered Glaucoma Detection & Monitoring System

**GenAI Ophthalmologist | KMIT Team G-489**

[🌐 Website](https://optim-bay.vercel.app/) · [📱 Download APK](https://optim-bay.vercel.app/optim_release.apk) · [🎥 Demo Video](https://www.youtube.com/watch?v=y8eBSF0POlE)

---

> *Revolutionizing eye care through advanced artificial intelligence — detecting glaucoma early, accurately, and accessibly.*

</div>

---

## 📌 Table of Contents

- [About the Project](#about-the-project)
- [Key Features](#key-features)
- [System Architecture](#system-architecture)
- [AI Models & Performance](#ai-models--performance)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Datasets Used](#datasets-used)
- [Deployment](#deployment)
- [Team](#team)

---

## 📖 About the Project

**Optim** is a cross-platform AI-powered mobile application designed to assist ophthalmologists and healthcare providers in the early detection and monitoring of **glaucoma** — one of the leading causes of irreversible blindness worldwide.

### 🚨 The Problem

Glaucoma affects over **80 million people globally**, yet it often goes undetected until vision loss is irreversible. The shortage of trained eye specialists, combined with the time-intensive manual analysis of fundus images, creates a critical gap in early diagnosis — especially in underserved and rural areas.

### 💡 Our Solution

Optim bridges this gap by bringing **three fine-tuned deep learning models** directly to a clinician's smartphone:

1. **Optic Disc & Cup Segmentation** — Precise boundary detection for CDR calculation
2. **Binary Glaucoma Classification** — Healthy vs. Glaucomatous fundus image detection
3. **Advanced Multi-class Classification** — Normal / Early-stage / Advanced glaucoma grading
4. **Visual Question Answering (VQA)** — Natural language Q&A on ophthalmic images

All of this is packaged in an intuitive Flutter mobile app backed by Firebase and secured with multi-factor authentication.

---

## ✨ Key Features

| Feature | Description |
|---|---|
| 🔍 **Optic Disc Segmentation** | Segments optic disc & cup from fundus images; calculates Cup-to-Disc Ratio (CDR) |
| 🧬 **Glaucoma Classification** | Binary and multi-class (Normal / Early / Advanced) prediction with confidence scores |
| 💬 **Visual Q&A (VQA)** | Ask clinical questions about fundus, OCT, and FA images in natural language |
| 📋 **Electronic Health Records (EHR)** | Store and retrieve complete patient history, reports, and examination data |
| 🔐 **Secure Authentication** | Email/password, Google Sign-In, and phone OTP (via Twilio) |
| 📲 **Cross-Platform** | Android app built with Flutter; works seamlessly across devices |
| ☁️ **Cloud-Ready** | Models deployed on Hugging Face Spaces & Render; data secured in Firebase Firestore |

---

## 🏗️ System Architecture

```
Doctor captures fundus image
         │
         ▼
   📱 Optim Mobile App (Flutter)
         │
    ┌────┴────────────────────┐
    │                         │
    ▼                         ▼
🔬 AI Analysis Pipeline    🔐 Firebase
    │                       (Auth + Firestore)
    ├── Segmentation CLIP       │
    │   (Optic Disc/Cup)        │
    │                      Saved Patient Reports
    ├── Classification CLIP      │
    │   (Binary: G vs NG)        ▼
    │                       📊 EHR Page
    ├── Advanced CLIP            └── Display Reports
    │   (Normal/Early/Advanced)
    │
    └── VQA CLIP
        (Any ophthalmic modality)
         │
         ▼
   Analysis & Reports → Back to Flutter App
```

The app uses a **two-stage CLIP architecture**:
- **Stage 1**: CLIP pre-training (image-text contrastive learning)
- **Stage 2**: Task-specific fine-tuning (segmentation / classification / VQA)

---

## 🤖 AI Models & Performance

### Segmentation Model
- **Architecture**: CLIP Image Encoder (ResNet-50) + U-Net Decoder
- **Dataset**: ORIGA-Light (~650 annotated fundus images)
- **Validation F1**: ~0.98 | **Pixel Accuracy**: ~99%
- **Task**: Optic disc & cup segmentation → CDR calculation

### Classification Model
- **Architecture**: Custom CLIP (ResNet CNN Image Encoder + Transformer Text Encoder)
- **Dataset**: REFUGE (1,200 fundus images)
- **Overall Accuracy**: **94.75%**
- **Glaucoma F1**: 0.95 | **Non-Glaucoma F1**: 0.95

### VQA Model
- **Architecture**: ResNet-50 Image Encoder + Transformer Decoder (Generative)
- **Dataset**: OphthalVQA — expanded from 600 → **3,120 IQA pairs**
- **Val BLEU**: ~0.88 | **Val ROUGE**: ~0.91

---

## 🛠️ Technology Stack

**Mobile App**
- Flutter (Dart) — cross-platform UI
- Firebase Auth — email, Google, phone OTP
- Firebase Firestore — patient data & reports
- Twilio Verify — SMS OTP via Node.js backend

**AI / ML**
- PyTorch & TensorFlow — model training
- OpenCV, NumPy, Matplotlib — image processing
- Scikit-learn — evaluation metrics
- CLIP architecture (contrastive pre-training + fine-tuning)

**Backend & Deployment**
- Node.js + Express — OTP verification server
- Docker — containerized deployment
- Render — backend API hosting
- Hugging Face Spaces — model inference endpoints

**Dev Tools**
- Jupyter Notebook, VS Code, Android Studio, GitHub

---

## 📁 Project Structure

```
Optim/
├── lib/                          # Flutter app source
│   ├── main.dart                 # App entry point, Firebase init
│   ├── auth_page.dart            # Welcome / auth landing screen
│   ├── login_page.dart           # Email & Google login
│   ├── signup_page.dart          # User registration
│   ├── forgot_password_page.dart # Password reset flow
│   ├── utils/
│   │   └── routes.dart           # Named route definitions
│   ├── services/
│   │   └── google_auth_service.dart  # Google Sign-In + Firestore
│   └── pages/
│       ├── home_page.dart                    # Dashboard
│       ├── vqa_page.dart                     # Visual Q&A interface
│       ├── ehr_page.dart                     # Electronic Health Records
│       ├── glaucoma_decision_page.dart       # Choose analysis type
│       ├── glaucoma_segmentation_page.dart   # Upload for segmentation
│       ├── glaucoma_segmentation_results_page.dart
│       ├── glaucoma_classification_page.dart # Binary classification
│       ├── glaucoma_classification_results_page.dart
│       ├── glaucoma_advance_classify.dart    # Multi-class grading
│       └── glaucoma_advance_results_page.dart
│
├── server.js                    # Node.js OTP server (Twilio)
├── .env                         # Firebase & Twilio credentials (not committed)
└── pubspec.yaml                 # Flutter dependencies
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (≥ 3.0)
- Node.js (≥ 18)
- Firebase project with Auth + Firestore enabled
- Twilio account (for phone OTP)
- Android device or emulator

### 1. Clone the Repository

```bash
git clone https://github.com/eluriNarsimhulu/Optim.git
cd Optim
```

### 2. Configure Environment Variables

Create a `.env` file in the project root:

```env
API_KEY=your_firebase_api_key
APP_ID=your_firebase_app_id
MESSAGING_SENDER_ID=your_sender_id
PROJECT_ID=your_project_id
STORAGE_BUCKET=your_storage_bucket

TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_VERIFY_SERVICE_SID=your_verify_service_sid
```

### 3. Install Flutter Dependencies

```bash
flutter pub get
```

### 4. Run the OTP Backend Server

```bash
npm install
node server.js
```

### 5. Run the App

```bash
flutter run
```

### 📱 Or Just Download the APK

> No setup needed — download and install directly on your Android device.

**[⬇️ Download APK](https://optim-bay.vercel.app/optim_release.apk)**

> Enable *"Install from Unknown Sources"* in your Android settings before installing.

---

## 📊 Datasets Used

| Dataset | Task | Size |
|---|---|---|
| **ORIGA-Light** | Optic disc & cup segmentation | ~650 annotated fundus images |
| **REFUGE** | Glaucoma vs. non-glaucoma classification | 1,200 labeled fundus images |
| **OphthalVQA** | Visual question answering | 600 → expanded to 3,120 IQA pairs |

---

## 🌐 Deployment

| Component | Platform | Link |
|---|---|---|
| Project Website | Vercel | [optim-bay.vercel.app](https://optim-bay.vercel.app/) |
| Model APIs | Hugging Face Spaces / Render | Hosted endpoints |
| OTP Server | Render | Live backend |
| APK | Vercel (static) | [Download](https://optim-bay.vercel.app/optim_release.apk) |

---

## ⚠️ Disclaimer

> Optim is designed for **educational and research purposes**. The diagnostic outputs of this system should not replace professional medical evaluation by a licensed ophthalmologist. Always consult a qualified healthcare provider for clinical decisions.

---

## 📄 License

This project is developed as part of an academic capstone at KMIT, Hyderabad. All rights reserved © 2025 Optim — GenAI Ophthalmology Team G-489.

---

<div align="center">

**Built with ❤️ by Team G-489 | KMIT, Hyderabad**

[🌐 Website](https://optim-bay.vercel.app/) · [📱 Download APK](https://optim-bay.vercel.app/optim_release.apk) · [🎥 Watch Demo](https://www.youtube.com/watch?v=y8eBSF0POlE)

</div>
