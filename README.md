# DiaFit ✨

DiaFit is a comprehensive health and lifestyle management platform designed to help users track and analyze their diet, medications, health metrics, and medical notes securely. It consists of a robust backend API, a user-friendly mobile application, and an administrative portal.

## 🚀 Project Architecture

The project is split into three main components:

### 1. DiaFit Backend API (`DiaFit.API`)
A powerful RESTful API built with **ASP.NET Core**.
- **Database**: SQL Server (LocalDB) managed via Entity Framework Core.
- **Authentication**: JWT (JSON Web Token) for secure API endpoint access.
- **Features**:
  - `DietLog`: Track daily food and nutrition intake.
  - `HealthLog`: Monitor health parameters.
  - `MedicationLog`: Keep track of medical prescriptions and schedules.
  - `Medical Notes`: Secure, AES-256 encrypted personal medical records.
  - `Food Analysis`: Intelligent analysis of dietary values via `FoodAnalysisService`.
  - `Emergency Contacts`: Manage emergency points of contact directly within the system.

### 2. DiaFit Mobile App (`diafit_mobile`)
A cross-platform mobile application built with **Flutter**.
- **State Management**: `provider` pattern.
- **Security**: `flutter_secure_storage` for securely storing JWT authentication tokens on the device.
- **Local Storage**: `shared_preferences` for managing lightweight user app preferences.
- Connects directly to the DiaFit backend API to deliver real-time data.

### 3. DiaFit Admin Portal (`DiaFit.Admin`)
A **Windows Forms (WinForms)** desktop application designed for administrative oversight.
- Features a real-time dashboard (`AdminDashboard`) to monitor platform usage and manage data endpoints.

## 🛠️ Tech Stack
- **Backend Architecture**: C#, ASP.NET Core Web API, Entity Framework Core, SQL Server
- **Mobile Application**: Dart, Flutter
- **Desktop/Admin Portal**: C#, Windows Forms (.NET)
- **Security paradigms**: JWT Bearer Authentication, AES-256 Database Encryption

## ⚙️ Getting Started

### Prerequisites
- [.NET SDK](https://dotnet.microsoft.com/download)
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- SQL Server (or SQL Server Express LocalDB)

### Running the API
1. Navigate to the `DiaFit.API` module:
   ```bash
   cd DiaFit/DiaFit.API
   ```
2. Apply Entity Framework database migrations (if required):
   ```bash
   dotnet ef database update
   ```
3. Run the API:
   ```bash
   dotnet run
   ```
   *(Swagger UI will be available at `https://localhost:<port>/swagger` in Development mode)*

### Running the Mobile App
1. Navigate to the `diafit_mobile` directory:
   ```bash
   cd DiaFit/diafit_mobile
   ```
2. Fetch Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application on an emulator or a connected physical device:
   ```bash
   flutter run
   ```

### Running the Admin Portal
1. Open the solution (`DiaFit.sln`) in Visual Studio.
2. Set `DiaFit.Admin` as the Startup Project.
3. Build and Run (F5). Alternatively, you can run `dotnet run` from within the `DiaFit.Admin` directory.

---
*Built for Hackathon*