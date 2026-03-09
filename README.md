# Kigali City Services 

A comprehensive mobile directory application built with Flutter and Firebase that allows users in Kigali to discover, rate, and manage essential services like hospitals, pharmacies, and cafés. The app features real-time location mapping, user authentication, and a community-driven listing system.

## 📱 Features

* **Authentication:** Secure Signup/Login with Email Verification enforcement.
* **Live Directory:** Browse services by category (Café, Police, Hospital, etc.).
* **Search & Filter:** Instant search by name and filtering by service type.
* **Interactive Maps:** View service locations on Google Maps and get turn-by-turn directions.
* **User Management:** Users can create, update, and delete their own listings.
* **Rating System:** Community-driven rating system (1-5 stars) for reliability.
* **Profile Management:** settings screen with user details and notification toggles.

## 🛠️ Tech Stack

* **Frontend:** Flutter (Dart)
* **Backend:** Firebase (Firestore Database, Authentication)
* **State Management:** Provider
* **Maps & Location:** Google Maps Flutter, Google Places API
* **Architecture:** MVVM (Model-View-ViewModel) pattern

## 📂 Project Structure

The project follows a modular architecture to separate UI, logic, and data:

* `lib/config/`: App-wide themes and color palettes (Dark Navy & Gold).
* `lib/models/`: Data models (`KigaliService`, `User`) with JSON serialization logic.
* `lib/providers/`: State management logic (`ServiceProvider`, `AuthProvider`) that bridges Firestore and the UI.
* `lib/services/`: Direct API calls to Firebase and Google Places.
* `lib/ui/screens/`:
    * `auth/`: Login and Signup screens.
    * `home/`: Main dashboard and category filtering.
    * `listing/`: CRUD interfaces (Add, Edit, Detail views).
    * `map/`: Full-screen map view.

## 🚀 Getting Started

### Prerequisites
* Flutter SDK installed (v3.0+)
* Firebase Project created

### Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/H-levison/kigali_city_services.git](https://github.com/your-username/kigali_city_services.git)
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Firebase Setup:**
    * Place your `google-services.json` file in `android/app/`.
    * Enable **Authentication** (Email/Password) and **Firestore** in your Firebase Console.
4.  **API Keys:**
    * Generate your API Key from Google Cloud Platform and add your Google Maps Key to the AndroidManifest.xml file :
    ```
    GOOGLE_MAPS_API_KEY=your_api_key_here
    ```
5.  **Run the App:**
    ```bash
    flutter run
    ```

## 📸 Screenshots
* *

---