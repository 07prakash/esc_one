# Dtox - Digital Detox App

A Flutter-based digital detox application designed to help users break free from mindless phone use and improve focus and productivity.

## 🎯 Features

- **Digital Detox Mode**: Restrict access to non-essential apps during detox sessions
- **Timer System**: Customizable detox duration with countdown timer
- **Essential Apps Access**: Allow access to Phone, Messages, Clock, Calendar, and Maps
- **Break Penalty**: ₹50 penalty for early exit to encourage commitment
- **Payment Integration**: Razorpay integration for penalty payments
- **Motivational Quotes**: Random inspirational quotes during detox
- **Screen Wake Lock**: Prevents screen sleep during detox mode
- **Progress Tracking**: Visual progress indicator and status messages

## 📱 Screens

1. **Splash Screen**: App logo and onboarding status check
2. **Intro Screens**: 4-step onboarding explaining app features
3. **Terms & Privacy**: User agreement screen
4. **Timer Setup**: Duration selection (30 minutes to 7 days)
5. **Detox Home**: Main screen with countdown and essential apps
6. **Settings**: Detox status and early exit options
7. **Early Exit**: Warning and penalty confirmation
8. **Payment**: Razorpay payment for early exit

## 🛠️ Technical Stack

- **Framework**: Flutter 3.8.1+
- **State Management**: ChangeNotifier for reactive UI
- **Persistence**: SharedPreferences for local storage
- **Payment**: Razorpay Flutter SDK
- **UI**: Material Design 3 with Google Fonts
- **Platform**: Android (primary), with iOS support

## 📦 Dependencies

```yaml
dependencies:
  flutter:sdk: flutter
  shared_preferences: ^2.2.2
  wakelock_plus: ^1.1.4
  android_intent_plus: ^4.0.3
  razorpay_flutter: ^1.3.5
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  intl: ^0.19.0
```

## 🚀 Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd dtox
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Razorpay** (for payment functionality):
   - Replace `YOUR_RAZORPAY_KEY` in `lib/services/payment_service.dart`
   - Add your actual Razorpay test/live key

4. **Run the app**:
   ```bash
   flutter run
   ```

## 📋 Usage

### First Launch
1. App shows splash screen and checks onboarding status
2. New users go through 4 intro screens explaining features
3. Accept terms and privacy policy
4. Select detox duration and start detox

### During Detox
- Countdown timer shows remaining time
- Only essential apps are accessible
- Settings screen shows progress and early exit option
- Screen stays awake to prevent accidental exits

### Early Exit
- Access settings and request early exit
- Confirm penalty payment of ₹50
- Complete payment via Razorpay
- Detox ends and returns to timer setup

## 🏗️ Project Structure

```
lib/
├── main.dart
├── screens/
│   ├── splash_screen.dart
│   ├── intro/
│   │   ├── intro_screen_1.dart
│   │   ├── intro_screen_2.dart
│   │   ├── intro_screen_3.dart
│   │   ├── intro_screen_4.dart
│   │   └── terms_and_privacy_screen.dart
│   ├── timer_setup_screen.dart
│   ├── detox_home_screen.dart
│   ├── settings_screen.dart
│   ├── early_exit_screen.dart
│   └── payment_screen.dart
├── widgets/
│   ├── app_icon_button.dart
│   ├── countdown_timer.dart
│   ├── motivational_quote.dart
│   └── rounded_button.dart
├── models/
│   └── detox_session.dart
├── services/
│   ├── timer_service.dart
│   ├── detox_enforcer.dart
│   ├── payment_service.dart
│   └── app_launcher_service.dart
└── utils/
    ├── constants.dart
    └── helpers.dart
```

## 🎨 Design Principles

- **Minimal UI**: Clean, distraction-free interface
- **Greyscale Theme**: Calm colors with accent highlights
- **Large Touch Targets**: Easy navigation and interaction
- **Progress Feedback**: Visual indicators for detox progress
- **Accessibility**: Support for text scaling and high contrast

## 🔧 Configuration

### Essential Apps
Modify `AppConstants.essentialApps` in `lib/utils/constants.dart` to change which apps are accessible during detox:

```dart
static const List<String> essentialApps = [
  'com.android.dialer', // Phone
  'com.android.mms', // Messages
  'com.android.deskclock', // Clock
  'com.google.android.calendar', // Calendar
  'com.google.android.apps.maps', // Maps
];
```

### Penalty Amount
Change the early exit penalty in `lib/utils/constants.dart`:

```dart
static const double earlyExitPenalty = 50.0; // ₹50
```

## 📱 Platform Support

- **Android**: Full support with app launching and wakelock
- **iOS**: Basic support (app launching may be limited)
- **Web**: Not supported (requires native platform features)

## 🔒 Permissions

The app requires the following Android permissions:
- `WAKE_LOCK`: Keep screen awake during detox
- `QUERY_ALL_PACKAGES`: Check if essential apps are installed

## 🚨 Important Notes

1. **Payment Integration**: Requires valid Razorpay credentials for production
2. **App Launching**: May not work on all Android devices due to manufacturer restrictions
3. **Screen Wake Lock**: May be overridden by system power settings
4. **Testing**: Use test payment credentials during development

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📞 Support

For support and questions, please open an issue on GitHub or contact the development team.
