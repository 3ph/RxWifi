# RxWifi

[![CI Status](http://img.shields.io/travis/3ph/RxWifi.svg?style=flat)](https://travis-ci.org/3ph/RxWifi)
[![Version](https://img.shields.io/cocoapods/v/RxWifi.svg?style=flat)](http://cocoapods.org/pods/RxWifi)
[![License](https://img.shields.io/cocoapods/l/RxWifi.svg?style=flat)](http://cocoapods.org/pods/RxWifi)
[![Platform](https://img.shields.io/cocoapods/p/RxWifi.svg?style=flat)](http://cocoapods.org/pods/RxWifi)
![Swift](https://img.shields.io/badge/in-swift4.0-orange.svg)

RxWifi is reactive wrapper for Wi-Fi functionality on iOS.
It allows you to connect to Wi-Fi network from your app and you can also observe Wi-Fi various changes:

- Wi-Fi is enable on the system level
- Wi-Fi is connected to AP
- Current connected SSID
- Current IPv4 address
- Current IPv6 address

## Usage

You can simply access the RxWifi by accessing `RxWifi.shared`.

#### Generic properties

- `isEnabled` - flag determining if the Wi-Fi is turned on in system settings.
- `isConnected` - flag determining if the system is currently connected to a Wi-Fi network.
- `connectedSsid` - name of the currently connected SSID (or nil if not connected).
- `ipv4` - IPv4 address (or nil if not connected).
- `ipv6` - IPv6 address (or nil if not connected).
- `securityType` - type of security of the network you want to connect to (`.wep`, `.wpa`, `.eap` (not supported yet)). Default `.wpa`.
- `persistConfiguration` - flag determining if the Wi-Fi configuration should be persisted after app finishes. Default `false`.
- `changeDetectionTimeInterval` - how often will the RxWifi poll for changes. Default is `0.5`.

#### Methods

- `connect(ssid,password)`
Tries to connect to Wi-Fi network with provided credentials. Uses `NetworkExtensions` framework to connect. Returns `Observable<ResultType>` with either `.success` or `.failure` (with error).

#### Rx observables

RxWifi also provides observables accessible through `rx` struct:

- `isConnectedChanged` - linked to `isConnected` property, changes checked every `changeDetectionTimeInterval` interval.
- `isEnabledChanged` - linked to `isEnabled` property, changes checked every `changeDetectionTimeInterval` interval.
- `ssidChanged` - linked to `connectedSsid` property, changes checked every `changeDetectionTimeInterval` interval.
- `ipv4Changed` - linked to `ipv4` property, changes checked every `changeDetectionTimeInterval` interval.
- `ipv6Changed` - linked to `ipv6` property, changes checked every `changeDetectionTimeInterval` interval.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Please note that the `connect(:)` method won't work Simulator since it depends on the `NetworkExtensions` framework. I've added `IOS_SIMULATOR` flag so you can at least build for Simulator.

## Requirements

Uses `RxSwift` framework. You also need to enable `Hotspot configuration` capability for your app.

## Installation

RxWifi is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RxWifi'
```

## Author

3ph, instantni.med@gmail.com

## License

RxWifi is available under the MIT license. See the LICENSE file for more info.
