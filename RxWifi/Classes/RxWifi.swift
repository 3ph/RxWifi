//
//  RxWireless.swift
//  GenieApp
//
//  Created by Tomas Friml on 10/11/17.
//  Copyright © 2017 Syrp Limited. All rights reserved.
//

import NetworkExtension
import RxSwift
import SystemConfiguration.CaptiveNetwork

public class RxWifi {
    
    public enum SecurityType {
        case wep
        case wpa
        case eap
    }
    
    public enum Result {
        case success
        case failure(Error)
    }

    public static let shared = RxWifi()
    
    /// WiFi enabled flag
    public var isEnabled: Bool {
        return _isEnabled
    }
    
    /// WiFi connected flag
    public var isConnected: Bool {
        return _isConnected
    }

    /// Name of connected SSID
    public var connectedSsid: String? {
        return _connectedSsid
    }
    
    /// Current IPv4 address
    public var ipv4: String? {
        return _ipv4
    }
    
    /// Current IPv6 address
    public var ipv6: String? {
        return _ipv6
    }
    
    /// Type of security of the WiFi network
    public var securityType : SecurityType = .wpa
    
    /// Determine if configuration should be persisted
    public var persistConfiguration: Bool = false

    public var changeDetectionTimeInterval : TimeInterval  = 0.5 {
        didSet {
            _changeDetectionTimerInterval = changeDetectionTimeInterval
            restartChangeDetectionTimer()
        }
    }
    
    public var isChangeDetectionEnabled : Bool = true {
        didSet {
            if isChangeDetectionEnabled {
                restartChangeDetectionTimer()
            } else {
                _changeDetectionTimer?.invalidate()
            }
        }
    }
    
    public var debugDescription: String {
        return """
        WiFi enabled: \(_isEnabled)
        WiFi connected: \(_isConnected)
        SSID: \(_connectedSsid ?? String("not connected"))
        """
    }
    
    
    /// Connect to Wi-Fi network with provided credentials.
    ///
    /// - Parameters:
    ///   - ssid: SSID of the Wi-Fi network
    ///   - password: Password.
    /// - Returns: Observable with connection attempt result.
    public func connect(ssid: String, password: String) -> Observable<Result> {
        
        #if !IOS_SIMULATOR
        let wifiConfig: NEHotspotConfiguration
        switch securityType {
        case .wep: wifiConfig = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: true)
        case .wpa: wifiConfig = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: false)
        case .eap: fatalError("Not implemented")
        }
        
        wifiConfig.joinOnce = !persistConfiguration
        
        NEHotspotConfigurationManager.shared.apply(wifiConfig) { error in
            if let error = error {
                return self._connectAttempt.on(.next(Result.failure(error)))
            } else {
                return self._connectAttempt.on(.next(Result.success))
            }
        }
            
        return _connectAttempt
        #else
        return Observable<Result>.just(.failure(NSError(domain: "Cannot connect in Simulator", code: 666, userInfo: nil)))
        #endif
    }
    
    public struct Rx {
        public var isConnectedChanged: Observable<Bool> {
            return _isConnectedChanged.asObservable()
        }
        
        public var isEnabledChanged: Observable<Bool> {
            return _isEnabledChanged.asObservable()
        }
        
        public var ssidChanged: Observable<String?> {
            return _ssidChanged.asObservable()
        }
        
        public var ip4Changed: Observable<String?> {
            return _ip4Changed.asObservable()
        }
        
        public var ip6Changed: Observable<String?> {
            return _ip6Changed.asObservable()
        }
        
        // MARK: Private
        fileprivate var _isConnectedChanged = BehaviorSubject<Bool>(value: false)
        fileprivate var _isEnabledChanged = BehaviorSubject<Bool>(value: false)
        fileprivate var _ssidChanged = BehaviorSubject<String?>(value: nil)
        fileprivate var _ip4Changed = BehaviorSubject<String?>(value: nil)
        fileprivate var _ip6Changed = BehaviorSubject<String?>(value: nil)
    }
    
    public let rx = Rx()
    
    // MARK: - Private
    fileprivate var _isEnabled = false
    fileprivate var _isConnected = false
    fileprivate var _changeDetectionTimerInterval: TimeInterval = 1.0
    fileprivate var _changeDetectionTimer: Timer?
    fileprivate var _connectedSsid: String?
    fileprivate var _ipv4: String?
    fileprivate var _ipv6: String?
    fileprivate var _connectAttempt = PublishSubject<Result>()
    
    fileprivate let _connectedInterface = "en0"
    fileprivate let _enabledInterface = "awdl0"
    
    fileprivate init() {
        refreshInterfaceData()
        restartChangeDetectionTimer()
    }
    
    fileprivate func restartChangeDetectionTimer() {
        _changeDetectionTimer?.invalidate()
        
        _changeDetectionTimer = Timer.scheduledTimer(withTimeInterval: _changeDetectionTimerInterval, repeats: true, block: { timer in
            self.refreshInterfaceData()
        })
    }
    
    fileprivate func refreshInterfaceData() {
        var connectedInterfaceCount = 0
        var enabledInterfaceCount = 0
        var ip4: String?
        var ip6: String?
        
        var ifaddrsPtr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddrsPtr) == 0 {
            var ifaddrPtr = ifaddrsPtr
            while let ptr = ifaddrPtr {
                let interface = ptr.pointee
                let ifa_name = String(cString: interface.ifa_name)
                let addr = interface.ifa_addr.pointee
                if ifa_name == _connectedInterface {
                    connectedInterfaceCount += 1
                    
                    // Convert interface address to a human readable string:
                    if addr.sa_family == AF_INET {
                        var address = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
                        getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                    &address, socklen_t(address.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        ip4 = String(cString: address)
                    } else if addr.sa_family == AF_INET6 {
                        var address = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
                        getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                    &address, socklen_t(address.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        ip6 = String(cString: address)
                        if let ip = ip6, let percent = ip.index(of: "%") {
                            ip6 = String(ip[..<percent])
                        }
                    }
                }
                if ifa_name == _enabledInterface {
                    enabledInterfaceCount += 1
                }
                ifaddrPtr = ifaddrPtr?.pointee.ifa_next
            }
            freeifaddrs(ifaddrsPtr)
        }
        
        let isEnabled = enabledInterfaceCount == 2
        let isConnected = connectedInterfaceCount == 3
        
        if isEnabled != _isEnabled {
            _isEnabled = isEnabled
            rx._isEnabledChanged.on(.next(_isEnabled))
        }
        
        if isConnected != _isConnected {
            _isConnected = isConnected
            rx._isConnectedChanged.on(.next(_isConnected))
        }
        
        if ip4 != _ipv4 {
            _ipv4 = ip4
            rx._ip4Changed.on(.next(_ipv4))
        }

        if ip6 != _ipv6 {
            _ipv6 = ip6
            rx._ip6Changed.on(.next(_ipv6))
        }
        
        var connectedSsid: String? = nil
        
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    connectedSsid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        
        if connectedSsid != _connectedSsid {
            _connectedSsid = connectedSsid
            rx._ssidChanged.on(.next(_connectedSsid))
        }
        
        NSLog("\(debugDescription)")
    }
}
