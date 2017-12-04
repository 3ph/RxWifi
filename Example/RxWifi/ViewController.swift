//
//  ViewController.swift
//  RxWifi
//
//  Created by 3ph on 11/16/2017.
//  Copyright (c) 2017 3ph. All rights reserved.
//

import RxSwift
import RxWifi
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var ssidTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var isEnabledLabel: UILabel!
    @IBOutlet weak var isConnectedLabel: UILabel!
    @IBOutlet weak var ip4Label: UILabel!
    @IBOutlet weak var ip6Label: UILabel!
    @IBOutlet weak var ssidLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupRx() {
        _wifi
            .rx
            .isConnectedChanged
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { connected in
                self.isConnectedLabel.text = "Wi-Fi is \(connected ? "connected" : "disconnected")"
            }).disposed(by: _disposeBag)
        
        _wifi
            .rx
            .isEnabledChanged
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { enabled in
                self.isEnabledLabel.text = "Wi-Fi is \(enabled ? "enabled" : "disabled")"
            }).disposed(by: _disposeBag)
        
        _wifi
            .rx
            .ssidChanged
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { ssid in
                self.ssidLabel.text = "SSID: \(ssid ?? "none")"
            }).disposed(by: _disposeBag)
        
        _wifi
            .rx
            .ip4Changed
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { ip in
                self.ip4Label.text = "IPv4: \(ip ?? "none")"
            }).disposed(by: _disposeBag)
        
        _wifi
            .rx
            .ip6Changed
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { ip in
                self.ip6Label.text = "IPv6: \(ip ?? "none")"
            }).disposed(by: _disposeBag)
    }

    @IBAction func onConnectButtonClicked(_ sender: Any) {
        if let ssid = ssidTextField.text, let password = passwordTextField.text {
            connectButton.isEnabled = false
            ssidTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
            _wifi.connect(ssid: ssid, password: password)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { result in
                    self.connectButton.isEnabled = true
                    switch result {
                    case .success:
                        // all good, wait for connectedStatus to change
                        break
                    case .failure(let error):
                        NSLog("Error: \(error.localizedDescription)")
                    }
            }).disposed(by: _disposeBag)
        }
    }
    
    // MARK: Private
    fileprivate let _wifi = RxWifi.shared
    fileprivate let _disposeBag = DisposeBag()
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == passwordTextField {
            onConnectButtonClicked(self)
        }
        return true
    }
}
