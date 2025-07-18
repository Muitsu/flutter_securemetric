package com.securemetric.myidreader.flutter_securemetric;

import static com.morpho.android.usb.USBManager.context;

import android.bluetooth.BluetoothAdapter;
import android.hardware.usb.UsbDevice;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.securemetric.myidreader.flutter_securemetric.fpservice.*;
import com.securemetric.myidreader.flutter_securemetric.fpswitch.*;
import com.securemetric.reader.myid.*;

import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** FlutterSecuremetricPlugin */
public class FlutterSecuremetricPlugin implements FlutterPlugin, MethodCallHandler, MyIDListener, MyIDPermissionListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private final String TAG = "SECURE_METRIC_SDK";
  private boolean usingFP = false;
  private MyID mReaderManager;
  private final DeviceFilterImpl mDeviceFilter = new DeviceFilterImpl();
  private FingerPrintManager fpManager = FingerPrintManager.getInstance();
  private SDKResponse sdkResponse;
  private AsyncTaskExecutorService<String, String, String> mTask = null;
  private String pluggedReader = "";
  private TaskCanceler mTaskCanceler;
  private final Handler mHandlerTask = new Handler(Looper.getMainLooper());

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.myKad/fingerprint");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "myKadSDK":
        usingFP = call.argument("usingFP");
        String license = call.argument("license");
        result.success(startMyKadSDK(license));
        break;
      case "turnOnFP":
        result.success(turnOnFP());
        break;
      case "turnOffFP":
        result.success(turnOffFP());
        break;
      case "connectScanner":
        result.success(fpManager.connectFPDevice(context));
        break;
      case "disconnectScanner":
        result.success(fpManager.disconnectFPDevice());
        break;
      case "getFPDeviceList":
        result.success(getFPDeviceList());
        break;
      case "readFingerprint":
        readFingerprint();
        result.success(null);
        break;
      case "dispose":
        onDispose();
        result.success(null);
        break;
      default:
        result.notImplemented();
    }
  }
  private boolean startMyKadSDK(String license) {
    if (mReaderManager != null) {
      Log.d(TAG, "Already Initialized");
      return;
    }

    mReaderManager = new MyID();
    mReaderManager.setOnReaderStatusChanged(this);
    mReaderManager.setOnPermissionListener(this);
    mReaderManager.setDeviceFilter(mDeviceFilter);

    try {
      mReaderManager.init(context, true, license);
      Toast.makeText(context, "SDK Initialized", Toast.LENGTH_SHORT).show();
      return true;
    } catch (MyIDException e) {
      Log.e(TAG, "SDK Init Error", e);
      return false;
    }
  }

  private boolean turnOnFP() {
    try {
      fpManager.initFPConnector(context);
      return true;
    } catch (Exception e) {
      Log.e(TAG, e.toString());
      return false;
    }
  }

  private boolean turnOffFP() {
    try {
      fpManager.turnOffSwitch(context);
      return true;
    } catch (Exception e) {
      Log.e(TAG, e.toString());
      return false;
    }
  }

  private String getFPDeviceList() {
    try {
      List<DeviceInfo> data = fpManager.getFPDeviceList(context);
      return DeviceInfo.listToJson(data).toString();
    } catch (Exception e) {
      return "Error: " + e.getMessage();
    }
  }

  private void readFingerprint() {
    sdkResponse = new SDKResponse("VERIFY_FP", "Verifying Fingerprint", "");
    channel.invokeMethod("VERIFY_FP", sdkResponse.toJson().toString());
    mTask = new ReadFingerprint(mReaderManager, context, channel);
    mTask.execute(pluggedReader);
    mTaskCanceler = new TaskCanceler(mTask, 0xFF);
    mHandlerTask.postDelayed(mTaskCanceler, 200_000);
  }

  private void onDispose() {
    if (mReaderManager != null) {
      mReaderManager.setOnUsbPermissionListener(null);
      mReaderManager.setOnReaderStatusChanged(null);
      mReaderManager.disconnectReader();
      mReaderManager.destroy();
      mReaderManager = null;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    onDispose();
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onCardStatusChange(String readerName, short status) {
    if (status == MyIDReaderStatus.READER_INSERTED) {
      sdkResponse = new SDKResponse("READER_INSERTED", "Insert SmartCard ...", "");
      channel.invokeMethod("READER_INSERTED", sdkResponse.toJson());
    } else if (status == MyIDReaderStatus.CARD_INSERTED) {
      sdkResponse = new SDKResponse("CARD_INSERTED", "Retrieve data ...", "");
      channel.invokeMethod("CARD_INSERTED", sdkResponse.toJson());
      pluggedReader = readerName;
      mTask = new ReadCard(mReaderManager, channel, readerName, usingFP, context);
      mTask.execute(readerName);
      mTaskCanceler = new TaskCanceler(mTask, 0xFF);
      mHandlerTask.postDelayed(mTaskCanceler, 200_000);
    } else if (status == MyIDReaderStatus.CARD_REMOVE) {
      sdkResponse = new SDKResponse("CARD_REMOVE", "Insert SmartCard ...", "");
      channel.invokeMethod("CARD_REMOVE", sdkResponse.toJson());
    } else if (status == MyIDReaderStatus.READER_REMOVED) {
      sdkResponse = new SDKResponse("READER_REMOVED", "Reader Detach", "");
      channel.invokeMethod("READER_REMOVED", sdkResponse.toJson());
    }
  }

  @Override
  public void onRequestUsbPermission(UsbDevice usbDevice) {}

  @Override
  public void onRequestBluetoothEnable(BluetoothAdapter bluetoothAdapter) {}
}
