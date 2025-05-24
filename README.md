# CalAI - Food Calorie Analyzer

An iOS app that analyzes food calories and nutrients from photos using OpenAI's Vision API.

## Features

- 📸 Take photos of food items
- 🤖 AI-powered food analysis using OpenAI Vision API
- 📊 Detailed calorie and nutrient breakdown
- 📅 Food history tracking with calendar view
- ✏️ Edit and customize analyzed data

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+
- OpenAI API Key

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/cal-ai-ios.git
```

2. Open `App Click Cal.xcodeproj` in Xcode

3. Add your OpenAI API key:
   - Create a new file named `Config.xcconfig`
   - Add your API key: `OPENAI_API_KEY = your_api_key_here`

4. Build and run the project

## Project Structure

```
App Click Cal/
├── App/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── Features/
│   ├── Camera/
│   ├── Analysis/
│   ├── History/
│   └── Settings/
├── Core/
│   ├── Models/
│   ├── Services/
│   └── Utils/
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

## Architecture

The app follows MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data structures and business logic
- **Views**: SwiftUI views and view controllers
- **ViewModels**: Business logic and data transformation
- **Services**: API calls and data persistence

## Development

1. Camera Feature:
   - Implement camera capture
   - Image processing and optimization

2. Analysis Feature:
   - OpenAI Vision API integration
   - Food recognition and calorie calculation

3. History Feature:
   - Calendar view implementation
   - Food log persistence

4. Settings:
   - User preferences
   - API configuration

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## Tech Stack

- Swift 5+
- Xcode (base project)
- Cursor AI IDE for AI-assisted development
- SweetPad VS Code extension for iOS development
- OpenAI Vision API for image analysis
- Local storage for logs (Core Data / UserDefaults)

---

## Installation and Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/pushpendra996/apps-click-cal-ai-ios.git
   cd apps-click-cal-ai-ios
