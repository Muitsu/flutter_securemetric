package com.securemetric.myidreader.flutter_securemetric.fpswitch;

public class DevicePlaceholder {
    private final Object mDeviceObject;
    private final DeviceInfo mDeviceInfo;

    DevicePlaceholder(Object deviceObject, DeviceInfo deviceInfo) {
        this.mDeviceObject = deviceObject;
        this.mDeviceInfo = deviceInfo;
    }

    public Object getDeviceObject() {
        return mDeviceObject;
    }

    public DeviceInfo getDeviceInfo() {
        return mDeviceInfo;
    }
}