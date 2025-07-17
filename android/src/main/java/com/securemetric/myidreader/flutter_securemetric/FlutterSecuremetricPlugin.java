package com.securemetric.myidreader.flutter_securemetric;

import android.bluetooth.BluetoothAdapter;
import android.hardware.usb.UsbDevice;

import androidx.annotation.NonNull;

import com.securemetric.reader.myid.MyIDListener;
import com.securemetric.reader.myid.MyIDPermissionListener;

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

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.myKad/fingerprint");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onCardStatusChange(String s, short i) {

  }

  @Override
  public void onRequestUsbPermission(UsbDevice usbDevice) {

  }

  @Override
  public void onRequestBluetoothEnable(BluetoothAdapter bluetoothAdapter) {

  }
}
