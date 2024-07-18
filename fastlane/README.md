fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### version_bump

```sh
[bundle exec] fastlane version_bump
```

Updates the app version to a new value

### presskit

```sh
[bundle exec] fastlane presskit
```

Generates and compresses a press kit archive

### purchases

```sh
[bundle exec] fastlane purchases
```

Sync in-app purchases to json file

----


## iOS

### ios build

```sh
[bundle exec] fastlane ios build
```

Push a new build to App Store Connect

### ios test

```sh
[bundle exec] fastlane ios test
```

Run tests

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Generate screenshots

### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

Upload screenshots

### ios code_signing

```sh
[bundle exec] fastlane ios code_signing
```



### ios code_signing_app_store

```sh
[bundle exec] fastlane ios code_signing_app_store
```



----


## Mac

### mac build

```sh
[bundle exec] fastlane mac build
```

Push a new build to App Store Connect

### mac code_signing

```sh
[bundle exec] fastlane mac code_signing
```



### mac code_signing_app_store

```sh
[bundle exec] fastlane mac code_signing_app_store
```



----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
