# Care Cub - Parenting Made Simple

<table>
  <tr>
    <td>
      <img width="330" height="330" alt="Image" src="https://github.com/user-attachments/assets/a22abad9-a0e1-4fa4-99ac-c83770d3c078" />
    </td>
    <td>
      <strong>Care Cub</strong> is a comprehensive Flutter application designed to simplify parenting by integrating AI-powered tools for baby cry classification, community support, and expert guidance. This all-in-one parenting assistant helps manage childcare responsibilities with features like cry detection, milestone tracking, nutrition guidance, doctors appointments and more.
    </td>
  </tr>
</table>

## Features

- **AI Cry Detection**: Uses  **YAMNet** model to analyze baby cries and identify needs (hunger, discomfort, tiredness)
- **Parenting Community**: Connect with other parents and access expert-verified content
- **Baby Tracking & Reminders**: Schedule vaccinations, feeding times, and appointments
- **Nutrition Guidance**: Get personalized dietary recommendations for your child
- **Doctor Consultation**: Book and manage appointments with pediatricians
- **Milestone Tracking**: Monitor physical, cognitive, and social development
- **Daycare Finder**: Discover and review local daycare centers with map integration
https://github.com/user-attachments/assets/7329f266-2255-46fb-9c4f-5866316be89b
## Demo Videos

<div style="display: flex; flex-wrap: wrap; gap: 20px; margin: 20px 0;">
  <div style="flex: 1 1 300px;">
    <h3>Cry Detection</h3>
    <video width="100%" controls>
      <source src="https://github.com/user-attachments/assets/7329f266-2255-46fb-9c4f-5866316be89b" type="video/mp4">
      Your browser does not support the video tag.
    </video>
  </div>
  <div style="flex: 1 1 300px;">
    <h3>Milestone Tracking</h3>
    <video width="100%" controls>
      <source src="https://github.com/user-attachments/assets/c0460ca1-9068-4411-b910-f874bb4b07f4" type="video/mp4">
      Your browser does not support the video tag.
    </video>
  </div>
  <div style="flex: 1 1 300px;">
    <h3>Daycare Finder</h3>
    <video width="100%" controls>
      <source src="https://github.com/user-attachments/assets/c0460ca1-9068-4411-b910-f874bb4b07f4" type="video/mp4">
      Your browser does not support the video tag.
    </video>
  </div>
</div>

## Installation

### Prerequisites
- Flutter SDK: Version >=3.3.1 <4.0.0
- Dart SDK
- Android Studio or Visual Studio Code with Flutter and Dart plugins
- Firebase project setup

### Firebase Setup
1. Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project
2. Add an Android app to your project and download the `google-services.json` file
3. Place the file in the `android/app` directory
4. Add an iOS app to your project and download the `GoogleService-Info.plist` file
5. Place the file in the `ios/Runner` directory
6. Enable Firebase Authentication, Firestore, and Storage in the Firebase Console

### Install Dependencies
```bash
flutter pub get
```

### Running the Application
```bash
flutter run
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.10.0
  cloud_firestore: ^5.6.1
  google_sign_in: ^6.2.2
  firebase_auth: ^5.4.0
  fluttertoast: ^8.2.10
  shared_preferences: ^2.3.5
  animated_splash_screen: ^1.3.0
  table_calendar: ^3.0.8
  font_awesome_flutter: ^10.4.0
  image_picker: ^1.0.7
  google_maps_flutter: ^2.2.0
  provider: ^6.0.0
  path_provider: ^2.1.2
  pdf: ^3.10.8
  open_filex: ^4.3.2
  shimmer: ^3.0.0
  http: ^1.2.2
  cached_network_image: ^3.4.1
  file_picker: ^10.1.9
  video_player: ^2.9.5
  chewie: ^1.11.1
  url_launcher: ^6.1.11
  share_plus: ^11.0.0
  cloudinary_flutter: ^1.3.0
  photo_view: ^0.15.0
  flutter_sound: ^9.28.0
  tflite_flutter: ^0.11.0
  cloudinary_public: ^0.23.1
  permission_handler: ^12.0.0+1
  intl: ^0.20.2
  audio_waveforms: ^1.3.0
  syncfusion_flutter_charts: ^29.2.5
  percent_indicator: ^4.2.5
  record: ^6.0.0
  audioplayers: ^6.4.0
  confetti: ^0.8.0
  youtube_player_flutter: ^9.1.1
  fl_chart: ^1.0.0
  yandex_mapkit: ^4.1.0
  geocoding: ^4.0.0
  geolocator: ^10.1.0
  location: ^5.0.3
  flutter_rating_bar: ^4.0.1
  flutter_stripe: ^11.5.0
```

## How to Use Care Cub

1. **Getting Started**
   - Register with email or Google account
   - Set up your child's profile with basic information
   - Grant necessary permissions for features like cry detection

2. **Main Features**
   - **Cry Detection**: Record your baby's cry to get instant analysis
   - **Tracking**: Log feedings, diaper changes, and sleep patterns
   - **Community**: Join discussions or ask questions in the parenting forum
   - **Appointments**: Schedule doctor visits and set reminders
   - **Nutrition**: Get personalized meal plans based on your child's age and needs

3. **Advanced Features**
   - Enable notifications for important reminders
   - Connect with local daycare centers and read reviews
   - Track developmental milestones and compare with averages

## Contributions

Contributions to Care Cub are welcome! If you find any issues or want to suggest new features, please open an issue or submit a pull request.

## License

This project is licensed under the GNU License - see the [LICENSE](LICENSE) file for details.

## Contact

For support or inquiries, please contact: [carecub-support@example.com](mailto:carecub-support@example.com)

---

**Thank you for choosing Care Cub - Your trusted parenting companion!**
