# DebateMate 🎯

<div align="center">

**AI-Powered Debate Training Platform**

*Train Your Mind, Find Your Voice*

[![Flutter](https://img.shields.io/badge/Flutter-3.1.0+-02569B?logo=flutter)](https://flutter.dev/)
[![Python](https://img.shields.io/badge/Python-3.8+-3776AB?logo=python)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Flask-3.0.0-000000?logo=flask)](https://flask.palletsprojects.com/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

## 📖 Overview

**DebateMate** is an intelligent debate training application that leverages cutting-edge AI and natural language processing to help users improve their argumentation skills. The platform provides real-time feedback on logical fallacies, generates optimized counterarguments, and offers personalized guidance to enhance critical thinking and debate performance.

### Key Features

- 🧠 **Real-time Fallacy Detection**: Identifies 13 types of logical fallacies using a fine-tuned BERT model
- ✨ **AI-Powered Counterarguments**: Generates refined, fallacy-free argument versions using T5 models
- 📊 **Comprehensive Feedback**: Detailed explanations and suggestions for argument improvement
- 🎤 **Voice Input**: Speech-to-text integration for natural debate interaction
- 📈 **Analytics Dashboard**: Track progress, session statistics, and debate performance
- 👥 **User Management**: Secure authentication with Firebase (Email/Password & Google Sign-In)
- 🔐 **Admin Panel**: Advanced analytics and user management for administrators
- 📱 **Cross-Platform**: Available on Android, iOS, Web, and Desktop

---

## 🏗️ Architecture

The DebateMate system consists of three main components:

```
┌─────────────────┐
│  Flutter App    │  ← Frontend (Mobile/Web)
│  (Dart)         │
└────────┬────────┘
         │ HTTP/REST
         ▼
┌─────────────────┐
│  Flask API      │  ← Backend (Python)
│  (Python)       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  ML Models      │  ← AI/ML Layer
│  (PyTorch)      │
└─────────────────┘
```

### System Components

1. **Frontend (Flutter/Dart)**
   - Cross-platform mobile and web application
   - Real-time UI with Riverpod state management
   - Firebase integration for authentication and data storage
   - Speech-to-text for voice input

2. **Backend API (Flask/Python)**
   - RESTful API endpoints for model inference
   - Model serving and optimization
   - CORS-enabled for mobile app integration

3. **ML Models**
   - **Fallacy Detection**: BERT-based classifier (`mempooltx/bert-base-fallacy-detection`)
   - **Counterargument Generation**: T5 model for argument refinement (`google/flan-t5-small`)

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** 3.1.0 or higher
- **Python** 3.8 or higher
- **Firebase Account** (for authentication and database)
- **Git** (for cloning the repository)

### Installation

#### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/debate-mate.git
cd debate-mate
```

#### 2. Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
pip install -r requirements.txt

# Download and setup models (models will be downloaded automatically on first run)
# Ensure you have sufficient disk space (~2GB for models)
```

#### 3. Frontend Setup

```bash
# Navigate to frontend directory
cd debatemate

# Install Flutter dependencies
flutter pub get

# Configure Firebase
# 1. Create a Firebase project at https://console.firebase.google.com
# 2. Add Android/iOS apps to your Firebase project
# 3. Download google-services.json (Android) and GoogleService-Info.plist (iOS)
# 4. Place them in the appropriate directories:
#    - android/app/google-services.json
#    - ios/Runner/GoogleService-Info.plist
# 5. Run: flutterfire configure (if using FlutterFire CLI)
```

#### 4. Configure Backend URL

Edit `debatemate/lib/core/constants/app_constants.dart`:

```dart
// For Android Emulator:
static const String? manualBackendUrl = null; // Uses http://10.0.2.2:5000

// For Physical Device:
static const String? manualBackendUrl = 'http://YOUR_COMPUTER_IP:5000';

// For Web:
static const String? manualBackendUrl = 'http://localhost:5000';
```



#### 5. Start the Backend Server

```bash
# From the backend directory
python app.py

The server will start on `http://localhost:5000`

#### 6. Run the Flutter App

```bash
# From the debatemate directory
flutter run

# Or specify a device:
flutter run -d chrome        # Web
flutter run -d android       # Android
```

---

## 📱 Usage

### For Users

1. **Sign Up / Sign In**
   - Create an account with email/password or use Google Sign-In
   - Verify your email (for email/password accounts)

2. **Start a Debate Session**
   - Navigate to the Debater Dashboard
   - Enter a debate topic
   - Start presenting your arguments

3. **Receive Feedback**
   - The AI analyzes your arguments in real-time
   - View detected fallacies and explanations
   - Read comprehensive feedback and suggestions
   - Review optimized counterarguments

4. **Track Progress**
   - View your debate history
   - Monitor session statistics
   - Review performance analytics

### For Administrators

1. **Access Admin Dashboard**
   - Sign in with the admin email (configured in `app_constants.dart`)
   - View platform-wide analytics
   - Monitor user activity
   - Manage user accounts

---

## 🛠️ Technology Stack

### Frontend
- **Flutter** 3.1.0+ - Cross-platform UI framework
- **Dart** - Programming language
- **Riverpod** - State management
- **GoRouter** - Navigation
- **Firebase** - Authentication & Firestore database
- **Flutter Animate** - Animations
- **FL Chart** - Data visualization

### Backend
- **Flask** 3.0.0 - Web framework
- **PyTorch** 2.0.0+ - Deep learning framework
- **Transformers** 4.30.0+ - HuggingFace transformers library
- **Flask-CORS** - Cross-origin resource sharing

### Machine Learning
- **BERT** - Fallacy detection model
- **T5** - Counterargument generation model
- **HuggingFace** - Model hub and transformers

### Infrastructure
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - NoSQL database
- **Firebase Hosting** - (Optional) Web hosting

---

## 📁 Project Structure

```
debate-mate/
├── backend/                 # Flask API backend
│   ├── app.py              # Main Flask application
│   ├── models/             # ML model files
│   │   ├── fallacy_model/  # BERT fallacy detection model
│   │   └── counter_model/  # T5 counterargument model
│   ├── training/           # Model training scripts
│   ├── requirements.txt    # Python dependencies
│   └── start_server.bat    # Windows startup script
│
├── debatemate/             # Flutter frontend
│   ├── lib/
│   │   ├── core/          # Core functionality
│   │   │   ├── constants/ # App constants
│   │   │   ├── models/    # Data models
│   │   │   ├── providers/ # State management
│   │   │   ├── router/    # Navigation
│   │   │   ├── services/  # API services
│   │   │   └── theme/     # App theming
│   │   └── features/      # Feature modules
│   │       ├── auth/      # Authentication
│   │       ├── dashboard/ # User & admin dashboards
│   │       └── home/      # Home screen
│   ├── assets/            # Images, icons, fonts
│   ├── android/           # Android-specific files
│   ├── ios/               # iOS-specific files
│   └── pubspec.yaml       # Flutter dependencies
│
└── README.md              # This file
```

---

## 🔌 API Endpoints

### Backend API (`http://localhost:5000`)

#### Health Check
```
GET /health
```
Returns server health status.

#### Analyze Argument
```
POST /analyze_argument
Content-Type: application/json

{
  "argument": "Your argument text here"
}
```

**Response:**
```json
{
  "FallacyDetected": "ad hominem",
  "Meaning": "Attacking the person instead of the argument",
  "Confidence": 0.85,
  "Feedback": "Comprehensive feedback from FALLACY_FEEDBACK...",
  "OptimizedCounterArgument": "Refined argument without fallacy"
}
```

#### Analyze with Feedback
```
POST /analyze_argument_with_feedback
Content-Type: application/json

{
  "text": "Your argument text here",
  "detected_fallacy": "optional"  // Optional: pre-detected fallacy
}
```

---

## 🧪 Testing

### Backend Testing

```bash
cd backend
python test_backend.py
```

### Frontend Testing

```bash
cd debatemate
flutter test
```

---

## 🐛 Troubleshooting

### Backend Connection Issues

**Problem**: App cannot connect to backend server

**Solutions**:
1. Ensure backend server is running (`python app.py`)
2. Check firewall settings (port 5000 must be open)
3. Verify backend URL in `app_constants.dart`
4. For physical devices, ensure device and computer are on the same Wi-Fi network

**Windows Firewall Fix**:
```bash
# Run as Administrator
netsh advfirewall firewall add rule name="Flask Backend" dir=in action=allow protocol=TCP localport=5000
```

### Model Loading Issues

**Problem**: Models fail to load or take too long

**Solutions**:
1. Ensure sufficient RAM (8GB+ recommended)
2. Check internet connection (models download on first run)
3. Verify disk space (models require ~2GB)
4. Consider using CPU optimization flags

### Firebase Authentication Issues

**Problem**: Sign-in fails or email verification doesn't work

**Solutions**:
1. Verify `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is correctly placed
2. Check Firebase project configuration
3. Ensure email verification is enabled in Firebase Console
4. Verify SHA-1/SHA-256 keys are added to Firebase project

---

## 📊 Model Information

### Fallacy Detection Model

- **Base Model**: `mempooltx/bert-base-fallacy-detection`
- **Architecture**: BERT (Bidirectional Encoder)
- **Task**: Sequence Classification
- **Classes**: 13 fallacy types
- **Input**: Max 512 tokens
- **Parameters**: ~100M

### Counterargument Generation Model

- **Base Model**: T5-based (fine-tuned)
- **Architecture**: Encoder-Decoder
- **Task**: Text-to-Text Generation
- **Purpose**: Generate refined, fallacy-free arguments

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow Flutter/Dart style guidelines
- Follow PEP 8 for Python code
- Write meaningful commit messages
- Add tests for new features
- Update documentation as needed

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **HuggingFace** for transformer models and libraries
- **Flutter Team** for the amazing framework
- **Firebase** for backend services
- **PyTorch** for deep learning capabilities
- All contributors and users of DebateMate

---

## 📧 Contact

For questions, suggestions, or support:

- **Email**: wahuabi@gmail.com
- **GitHub Issues**: [Open an issue](https://github.com/yourusername/debate-mate/issues)

---

## 🗺️ Roadmap

- [ ] Support for more fallacy types
- [ ] Multi-language support
- [ ] Advanced analytics and insights
- [ ] Debate tournament mode
- [ ] Collaborative debate sessions
- [ ] Mobile app store releases
- [ ] Web deployment
- [ ] API rate limiting and optimization

---

<div align="center">

**Made with ❤️ for better argumentation skills**

⭐ Star this repo if you find it helpful!

</div>

