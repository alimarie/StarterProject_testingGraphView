//
//  DeviceViewController.swift
//  SwiftStarter
//
//  Created by Stephen Schiffli on 10/20/15.
//  Copyright © 2015 MbientLab Inc. All rights reserved.
//

import UIKit
import MetaWear

class DeviceViewController: UIViewController {
    
    // LABELS
    @IBOutlet weak var deviceStatus: UILabel!
    @IBOutlet weak var TemperatureLabel: UILabel!
    @IBOutlet weak var LightLabel: UILabel!
    @IBOutlet weak var HumidityLabel: UILabel!
    
    
    
    // BUTTONS
    @IBOutlet weak var StartMonitoringButton: UIButton!
    @IBOutlet weak var StopMonitoringButton: UIButton!
    @IBOutlet weak var StartStreamingButton: UIButton!
    @IBOutlet weak var StopStreamingButton: UIButton!
    
    // DATA
    var accelerometerBMI160Data = [MBLAccelerometerData]()
    
    // GRAPH VIEWS
    //@IBOutlet weak var AccelerometerGraphView: APLGraphView!
    
    // DEVICES
    var device: MBLMetaWear!
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        device.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions.new, context: nil)
        device.connectAsync().success { _ in
            self.device.led?.flashColorAsync(UIColor.green, withIntensity: 1.0, numberOfFlashes: 3)
            NSLog("We are connected")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        device.removeObserver(self, forKeyPath: "state")
        device.led?.flashColorAsync(UIColor.red, withIntensity: 1.0, numberOfFlashes: 3)
        device.disconnectAsync()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        OperationQueue.main.addOperation {
            switch (self.device.state) {
            case .connected:
                self.deviceStatus.text = "Connected";
            case .connecting:
                self.deviceStatus.text = "Connecting";
            case .disconnected:
                self.deviceStatus.text = "Disconnected";
            case .disconnecting:
                self.deviceStatus.text = "Disconnecting";
            case .discovery:
                self.deviceStatus.text = "Discovery";
            }
        }
    }
    
    
    //**********************************************************
    //              UPDATING SETTINGS FUNCTIONS
    //**********************************************************
    
    func updateAccelerometerBMI160Settings() {
        let accelerometerBMI160 = self.device.accelerometer as! MBLAccelerometerBMI160
        
        accelerometerBMI160.fullScaleRange = .range2G
        //self.accelerometerGraphView.fullScale = 2
        accelerometerBMI160.sampleFrequency = 50
    }
    
    
    
    
    //**********************************************************
    //                   TRACKING FUNCTIONS
    //**********************************************************
    
    @IBAction func StartMonitoring(_ sender: Any) {
        print("Start Monitoring tapped")
        
        StartMonitoringButton.isEnabled = false
        StopMonitoringButton.isEnabled = true
        device.led?.flashColorAsync(UIColor.magenta, withIntensity: 1.0)
            
            // ----- Track Movement -----
            updateAccelerometerBMI160Settings()
            device.accelerometer!.dataReadyEvent.startLoggingAsync()
    }
    
    @IBAction func StopMonitoring(_ sender: Any) {
        print("Stop Monitoring tapped")
            
        StartMonitoringButton.isEnabled = true
        StopMonitoringButton.isEnabled = false
        device.led?.setLEDOnAsync(false, withOptions: 1)
        
        //device.accelerometer!.dataReadyEvent.stopLoggingAsync()
       
      
        
            //-----  ACCELEROMETER -----
  /*          let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
            hud.mode = .determinateHorizontalBar
            hud.label.text = "Downloading..."
            device.accelerometer!.dataReadyEvent.downloadLogAndStopLoggingAsync(true) { number in
                hud.progress = number
                }.success { array in
                    self.accelerometerBMI160Data = array as! [MBLAccelerometerData]
                    for obj in self.accelerometerBMI160Data {
                        self.accelerometerGraphView.addX(obj.x, y: obj.y, z: obj.z)
                    }
                    hud.mode = .indeterminate
                    hud.label.text = "Clearing Log..."
                    self.logCleanup { error in
                        hud.hide(animated: true)
                        if error != nil {
                            self.connectDevice(false)
                        }
                    }
                }.failure { error in
                    self.connectDevice(false)
                    hud.hide(animated: true)
            }
            
     
*/
        
        
    }
    
    
    @IBAction func StartStreaming(_ sender: Any) {
        print("Start Streaming tapped")
    }
    
    @IBAction func StopStreaming(_ sender: Any) {
        print("Stop Streaming tapped")
    }
    
    
    
    
}
