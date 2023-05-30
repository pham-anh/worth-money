# my_financial

## Init firebase hosting

```bash
curl -sL https://firebase.tools | bash
firebase login
firebase projects:list
firebase init # At this step select 'build/web' for public directory if build for web
```

## Build and deploy web version

This is no longer supported by this app but the step is kept for reference.

```
flutter build web
firebase deploy
```

### Automate deployment with Cloud Build

Build firebase command and flutter command and push them to Container Registry for later use in Cloud Build trigger

 - https://cloud.google.com/build/docs/deploying-builds/deploy-firebase

### Build firebase command

```
git clone https://github.com/GoogleCloudPlatform/cloud-builders-community.git
```

### Build flutter command

```
cd cloud-builders-community/flutter
```

Open Dockerfile, comment out lines relating to Android, then run the command below

```
gcloud builds submit --config cloudbuild.yaml .
```

## How to distribute (release) iOS app version

* Work in project `production-my-finance`
* Work in branch `release`
    * create new `release` branch from `develop` for every release
    * after every release, delete `release` branch
* Update `version` in `pubspec.yaml`
* Open Xcode, update `Version` and `Build` number
* Run `flutter build ipa --build-name <Version in Xcode> --build-number <Build in Xcode>`
* Open the build Runner.xcarchive in Xcode: `open /Users/quynhanhpham/my-project/production/production-my-finance/build/ios/archive/Runner.xcarchive`
* Validate the Runner.xcarchive and upload it to AppStoreConnect by: `Validate App`, then `Distribute App` buttons
* From AppStoreConnect (in browser), either prepare for App Store review submission or distribute it for testing using TestFlight

https://docs.flutter.dev/deployment/ios

Run `flutter build ipa --build-name 1.8.3 --build-number 1`

-  --build-name = Runner > Target Runner > General > Identity > Version
- --build-number = Runner > Target Runner > General > Identity > Build

Fix any errors if warned

If successful then it will be:

```
quynhanhpham@pqa ~/my-project/production/production-my-finance (release)$ flutter build ipa --build-name 1.0.0 --build-number 2
Archiving icu.pqa.myfinanceProduction...
Automatically signing iOS for device deployment using specified development team in Xcode project: QC79NCRZ87
Running pod install...                                              8.8s
Running Xcode build...
 └─Compiling, linking and signing...                        11.2s
Xcode archive done.                                         521.4s
Built /Users/quynhanhpham/my-project/production/production-my-finance/build/ios/archive/Runner.xcarchive.

💪 Building with sound null safety 💪

Building App Store IPA...                                          68.9s
Built IPA to /Users/quynhanhpham/my-project/production/production-my-finance/build/ios/ipa.
To upload to the App Store either:
    1. Drag and drop the "build/ios/ipa/*.ipa" bundle into the Apple Transport macOS app
    https://apps.apple.com/us/app/transporter/id1450874784
    2. Run "xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa --apiKey your_api_key --apiIssuer your_issuer_id".
       See "man altool" for details about how to authenticate with the App Store Connect API key.
```


Open the build in Xcode

```
Open build/ios/archive/Runner.xcarchive
```

From there, proceed to validate app.
If the validation is passed, proceed to Distribute (Upload to AppStore Connect)

Continue with works on branch: after a release

* Create a version tag on `release` branch
* Merge `release` branch into `master`
* Merge `master` branch into `develop`
* Delete `release` branch

***
**Release branch only exists in release period**
***

### Flutter update

```
flutter upgrade
```

The output

```
$ flutter upgrade
Upgrading Flutter to 3.1.0-0.0.pre.1485 from 2.13.0-0.0.pre.270 in /Users/xxxx/flutter...
Downloading Darwin x64 Dart SDK from Flutter engine 2013801d213369d4ccbc5acb0808ed916bdd000d...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed

  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0  203M    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0
...
```

When it failed, I did the following to fix it.

```
git clean -xfd
git stash save --keep-index
git stash drop
git pull
flutter doctor
```



