# CONTRIBUTING

Xcode will build 2 different apps when the bundle ids are different. Otherwise, we will have the same app.

## dev project

Connect to firebase

```
flutterfire configure --project <dev firebase> --out lib/firebase_options.dart --ios-bundle-id icu.pqa.myfinance
```

Run dev

```bash
## No flag = --debug, this will be build and run with bundle id icu.pqa.myfinance
flutter run
```

## prod project

```
flutterfire configure --project <prod firebase> --out lib/firebase_options.dart --ios-bundle-id icu.pqa.myfinanceProduction
```

Run prod


```bash
# Use --release to run or build with bundle id icu.pqa.myfinanceProduction
flutter run --release
```

Build prod

```
flutter build ios --release
```

## Why 2 Xcode (VSCode) projects for dev and prod?

If we do in 1 project, it is hard to separate firebase config, (or I don't know how to make it easy).
I load the firebase options for both dev and prod in the same project, identify them by passing --dart-define on build and run, but it warned me that `Firebase App named '[DEFAULT]' already exists`

Also I don't want to mix dev and prod config into 1 project which may cause operation mistake in the future.


## About bundle ID

Although we have 2 projects, we want the source code as the same as possible. So the bundle for each environment (debug, release, production) should be the same.

* debug, profile: `icu.pqa.myfinance` -> this bundle id is **only** registered in dev firebase
* release: `icu.pqa.myfinanceProduction` -> this bundle is **only** registered in prod firebase

When we run with --release, an app with bundle id `icu.pqa.myfinanceProduction` will be built, firebase project in `firebase_options` of that project will be used.

### Some possible mistakes

Basically, we build with `--release` in production project -> app with `icu.pqa.myfinanceProduction` will be built -> pointing to `prod firebase`.

1. If by any mistake, we run with --release in dev project --> app with icu.pqa.myfinanceProduction will be built --> pointing to dev firebase --> it doesn't harm the production.
1. Here, if we also configure dev project to point to prod firebase --> THE PROBLEM IS BORN. So we have 2 chances to keep the problem not occur.

## Troubleshooting

### Cannot install pod

* cd to ios
* Delete Podfile.lock
* Run pod install

### Update major version of dependencies

* flutter pub upgrade --major-version

### Fix dart syntax error

* dart fix --dry-run
* dart fix --apply

### [VERBOSE-2:dart_isolate.cc(144)] Could not prepare isolate.

* flutter clean
* flutter run
