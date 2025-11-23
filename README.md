# Namma Bus 🚌

Namma Bus is a Flutter-based public transport utility app designed to help users easily find bus routes, schedules, and trip details. It focuses on accessibility and a user-friendly experience for all demographics.

## 🌟 Features

### 🔍 Smart Route Finder
- **Source & Destination Search**: Easily find buses between two locations.
- **Location Suggestions**: Intelligent autocomplete suggestions for source and destination fields.
- **Time-Based Filtering**: Filter buses based on your departure time to see only relevant schedules.

### 📋 Comprehensive Bus Details
- **Route Information**: Clear display of starting point, destination, and route distance.
- **Schedule Statistics**:
  - **Next Trip (Same Bus)**: Know exactly when the specific bus will depart next.
  - **Next Bus (Any Bus)**: Find the next available bus on the same route, regardless of the bus number.
  - **Total Trips**: View the total number of trips a bus makes in a day.
- **Distance Display**: Route distance displayed in kilometers.

### 🌐 Multi-Language Support
- **Trilingual Interface**: Toggle seamlessly between **English**, **Kannada**, and **Hindi**.
- **Localized Content**: All app labels and messages are translated for a localized experience.

### 🎨 User Experience & Design
- **Public Welfare Design**: High-contrast, large typography, and clear icons designed for accessibility (elderly-friendly).
- **Smooth Animations**:
  - Hero animations for bus numbers during transitions.
  - Subtle entry animations for the app bar and list items.
- **Clean Interface**: Clutter-free design focusing on essential information.

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Data Source**: Excel (`.xlsx`) integration for offline route data.
- **State Management**: `ValueNotifier` for lightweight state management (Localization).
- **Packages**:
  - `excel`: For parsing bus schedule data.
  - `google_fonts`: For modern, readable typography (`Public Sans`).
  - `intl`: For time formatting.

## 🚀 Getting Started

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/Hellf0rg0d/nammabus.git
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the app**:
    ```bash
    flutter run
    ```

## 📂 Project Structure

- `lib/main.dart`: Entry point of the application.
- `lib/data_screen.dart`: Main screen for searching and listing buses.
- `lib/bus_detail_screen.dart`: Detailed view of a specific bus route.
- `lib/localization.dart`: Localization logic and string resources.
- `assets/FQR.xlsx`: Database file containing bus routes and schedules.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
