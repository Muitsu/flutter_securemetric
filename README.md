# Securemetric SDK Plugin (Unofficial)
A Flutter plugin created with integrated support for the native Securemetric SDK.


## 📱 Device Support

| v11 |  v20  |  Others  |
| :-----: | :---: | :---: |
|✅|✅|⚠️|

## 🔒 Security Considerations
- The SDK is designed with built-in safety for fingerprint operations.
- If USB debugging (ADB) is enabled, the fingerprint scanner will automatically disconnect after connection.
- This helps prevent misuse during development or rooted device scenarios.

> ⚠️ **Security Note**
>
> Once the fingerprint scanner is connected, if the system detects that the device is running in **USB debugging mode (wired debugging)**, the scanner will be **automatically disconnected** to prevent unauthorized access or tampering during development.
>
> This is a security feature and applies when connecting via `connectFPScanner()`. Ensure USB debugging is disabled for production environments.
## ⚠️ Important Note About License & App ID

The license key used for initializing the SDK is **tied to the `app_id`** (application ID / package name) of your app.

- ✅ **Make sure the license was generated specifically for your app's package name.**
- ❌ **If you attempt to use a license purchased or generated for a different `app_id`, the fingerprint functionality will not work.**

This restriction is enforced by the SDK provider to ensure license integrity and prevent unauthorized usage across different applications.

## Installation

Go to the `pubspec.yaml` directory

```yaml
 dependencies:
   ...
   flutter_securemetric:
      git:
          url: https://github.com/Muitsu/flutter_securemetric.git
          ref: main
```

## Getting Started
Learn more at [example app !](https://github.com/Muitsu/flutter_securemetric/tree/main/example)
### Import
```dart
import 'package:flutter_securemetric/flutter_securemetric.dart';
```


### Initialize Controller
To get started, initialize the `SecuremetricController` in your widget's `initState`.
```dart
final SecuremetricController sController = SecuremetricController();

@override
void initState() {
  super.initState();

  sController.init(
    license: null, // Or provide your license string here
    verifyFP: true, // Enables fingerprint verification
    context: context, // Required for showing native messages or Snackbars
    device: SecuremetricDevice.v11, // Set the target device version
  );

  WidgetsBinding.instance.addObserver(this);
}
```

###  Handle app life cycle:
```dart
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      sController.close();
    }
  }
```
###  Assign the controller that you have created earlier to SecuremetricWidget 
```dart
        SecuremetricWidget(
            controller: sController,
            onCardSuccess: (val) {},
            onVerifyFP: (val) {
            if (!val) return;
            Future.delayed(const Duration(milliseconds: 800), () {
                widget.onVerifyFP(val);
                Navigator.pop(context);
            });
            },
            builder: (context, msg) {
            final readerStatus = ReaderStatus.queryStatus(msg);

            return Center(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    SizedBox(height: constraint.maxHeight * .12),
                    readerStatus.isLoading
                        ? Padding(
                            padding: EdgeInsets.only(
                            top: constraint.maxHeight * .1,
                            ),
                            child: const CircularProgressIndicator(),
                        )
                        : FittedBox(child: readerStatus.widget),
                    SizedBox(height: constraint.maxHeight * .04),
                    readerStatus.isNotBlink
                        ? Text(
                            readerStatus.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            ),
                        )
                        : Text(
                            readerStatus.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            ),
                        ),
                    Visibility(
                    visible: readerStatus.showTryAgain,
                    child: ElevatedButton(
                        onPressed: sController.tryAgain,
                        child: const Text("Try Again"),
                    ),
                    ),
                ],
                ),
            );
            },
        ),
```
## 📘 ReaderStatus Enum

The `ReaderStatus` enum represents the various states of card and fingerprint interactions in the UI. Each status includes:

- A `title` — human-readable label for display.
- A `widget` — UI component shown to the user (e.g., icon and message).
- A `query` — keyword used for identifying the status from native or incoming messages.

### 🔄 Status Reference

| Enum Value     |Query String               | Description                      |
|----------------|----------------------------|----------------------------------|
| `insert`       |  `insert card`              | Prompt to insert a card          |
| `cardSuccess`  | `card successful`          | Indicates successful card read   |
| `cardFailed`   |  `and try again`            | Indicates card read failure      |
| `remove`       |`remove card`              | Prompt to remove card            |
| `insertFP`     |  `place your fingerprint` | Prompt to place fingerprint      |
| `successFP`    | `verification successful`  | Indicates fingerprint verified   |
| `failedFP`     |  `error: please`            | Indicates fingerprint failed     |
| `loading`      |  `loading`                  | General loading state            |
| `loadingFP`    | `initialize fingerprint`   | Initializing fingerprint hardware|

---

### 🧠 Behavior Flags

The enum includes helper properties to make UI logic easier:

- `isLoading`  
  Returns `true` if status is either `loading` or `loadingFP`.

- `isNotBlink`  
  Returns `true` if status is `cardSuccess` or `successFP`.  
  Useful to **stop animations or blinking indicators**.

- `showTryAgain`  
  Returns `true` if status is `failedFP`.  
  Can be used to show a **"Try Again"** button or alert.

---

### 🔍 Matching from Query

You can map an incoming string (e.g., from native platform or SDK) to a `ReaderStatus` like this:

```dart
ReaderStatus status = ReaderStatus.queryStatus("card successful");
```


## List of Functions

### SDK Control Functions
- `FlutterSecuremetric.callSDK`  
  Initializes the SDK, with optional license key and fingerprint usage toggle.

- `FlutterSecuremetric.disposeSDK`  
  Disposes the SDK and cleans up resources.

### Fingerprint Scanner Management
- `FlutterSecuremetric.turnOnFP`  
  Turns on the fingerprint scanner device.

- `FlutterSecuremetric.turnOffFP`  
  Turns off the fingerprint scanner device.

- `FlutterSecuremetric.connectFPScanner`  
  Connects to the fingerprint scanner hardware.

- `FlutterSecuremetric.disconnectFPScanner`  
  Disconnects from the fingerprint scanner hardware.

- `FlutterSecuremetric.readFingerprint`  
  Requests to read a fingerprint.

### Device Information
- `FlutterSecuremetric.getFPDeviceList`  
  Returns a list of available fingerprint devices.

### Event Listening
- `FlutterSecuremetric.sdkListener`  
  Listens to native SDK events and triggers relevant callback functions:
  - `onIdle` – Called when the reader is idle or card is removed.
  - `onReadCard` – Called when a card is inserted.
  - `onSuccessCard(SdkResponseModel data)` – Called when card reading is successful.
  - `onErrorCard` – Called when card reading fails.
  - `onVerifyFP` – Called when fingerprint verification is triggered.
  - `onSuccessFP` – Called when fingerprint verification is successful.
  - `onErrorFP` – Called when fingerprint verification fails or scanner error occurs.


## Maintainers
* [`Muitsu`](https://github.com/Muitsu)
