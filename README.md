# club_me


# Deploying

- pubspec.yaml: change version
- services/

# Allgemeines Design
in der main macht `scaffoldBackgroundColor: Colors.black` den appbar hintergrund schwarz

# Nützliche Befehle

https://javiercbk.github.io/json_to_dart/ 



## Update der Icons außerhalb der App
- flutter pub run flutter_launcher_icons:main
## Erstellung der Hive-spezifischen Dateien und Verlinkungen
- flutter packages pub run build_runner build

# Update des splash screens
dart run flutter_native_splash:create

# iOS Privacy

I added the ios/PrivacyInfo.xcprivacy file because flutter_background_geolocation said that 
apple requires it


# Nützliche Ressourcen

https://hussainmustafa.com/integrating-google-maps-in-flutter-for-dynamic-location-tracking/

## Google Sign In without firebase

https://medium.com/codebrew/flutter-google-sign-in-without-firebase-3680713966fb


## iOS Permissions

I removes the following ones because I dont see us using them actively.


		<key>NSMotionUsageDescription</key>
		<string>Needed for the location service</string>

		<key>NSBluetoothAlwaysUsageDescription</key>
        <string>Bluetooth Access Required</string>

        <array>
         <dict>
          <key>CFBundleTypeRole</key>
          <string>Editor</string>
          <key>CFBundleURLSchemes</key>
          <array>
           <string>com.googleusercontent.apps.947015013780-cfmc26giatfe8tsgf0eg3im36h0qsvj0.apps.googleusercontent.com</string>
          </array>
         </dict>
        </array>