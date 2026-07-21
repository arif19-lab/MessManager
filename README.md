<h1 align="center">🍲 Mess Manager</h1>

<p align="center">
  A premium, highly responsive, and feature-rich application designed to manage mess (hostel/shared living) expenses, meals, and members effortlessly. Built with Flutter for Android, Windows, and the Web.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
</p>

---

## ✨ Key Features

- **🌐 Cross-Platform:** Seamlessly runs on Android, Windows (Desktop), and Web Browsers.
- **🔐 Secure Authentication:** Powered by Firebase Authentication. Supports Email/Password, Google Sign-In, and secure Password Recovery.
- **📶 Offline Mode:** Core features remain accessible even without an internet connection.
- **🎨 Premium UI/UX:** Stunning glassmorphism design, vibrant gradients, dynamic animations, and full Dark/Light mode support.
- **📱 Responsive Layout:** Perfectly scales across mobile screens and desktop windows with notch/safe-area protection.
- **💰 Expense & Meal Tracking:** Easily track daily meals, shopping expenses, and individual balances.

## 🚀 Live Demo & Downloads

- **Web Version (Live):** [Play with the App Online](https://mess-manager-6dcce.web.app)
- **Android & Windows:** Head over to our [Releases Page](../../releases) to download the latest `.apk` and `.exe` files!

## 🛠️ Tech Stack

- **Frontend:** Flutter & Dart
- **Backend/Database:** Firebase (Auth, Cloud Firestore)
- **State Management:** Provider
- **Local Storage:** SQLite (via sqflite), Shared Preferences

## 💻 Running Locally

If you want to run this project on your own machine, follow these steps:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/arif19-lab/MessManager.git
   ```
2. **Navigate to the directory:**
   ```bash
   cd MessManager
   ```
3. **Install dependencies:**
   ```bash
   flutter pub get
   ```
4. **Run the app:**
   ```bash
   flutter run
   ```

## 📦 Building the Windows Installer

To create a professional `Setup.exe` file for Windows distribution, we use **Inno Setup**.

1. Download and install [Inno Setup Compiler](https://jrsoftware.org/isdl.php).
2. Build the Flutter Windows app first:
   ```bash
   flutter build windows
   ```
3. Open the `mess_manager_setup.iss` file located in the root of the project using Inno Setup.
4. Update the `AppVersion` and `OutputBaseFilename` if you are releasing a new version.
5. Click **Build > Compile** (or press `Ctrl + F9`).
6. The compiled `Setup.exe` will be generated in `build/windows/installer/`.

## 📜 License
This project is for personal and educational use. Feel free to explore the code, learn, and contribute!
