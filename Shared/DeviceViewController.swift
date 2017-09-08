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
    var gyroBMI160Data = [MBLGyroData]()
    var lightData = [MBLNumericData]()
    var humidityData = [MBLNumericData]()
    var temperatureData = [MBLNumericData]()
    
    // GRAPH VIEWS
    var count = 0
   // @IBOutlet weak var AccelerometerGraphView: APLGraphView!
    
    // DEVICES
    var device: MBLMetaWear!
    
    // STREAMING
    var streamingEvents: Set<NSObject> = []
    
    // EVENTS
    var humidityEvent: MBLEvent<MBLNumericData>!
    var temperatureEvent: MBLEvent<MBLNumericData>!
    var lightEvent: MBLEvent<MBLNumericData>!
    
    // LOGGING STUFF
    var isObserving = false {
        didSet {
            if self.isObserving {
                if !oldValue {
                    self.device.addObserver(self, forKeyPath: "state", options: .new, context: nil)
                }
            } else {
                if oldValue {
                    self.device.removeObserver(self, forKeyPath: "state")
                }
            }
        }
    }

    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        device.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions.new, context: nil)
        device.connectAsync().success { _ in
            self.device.led?.flashColorAsync(UIColor.green, withIntensity: 1.0, numberOfFlashes: 3)
            NSLog("We are connected")
        }
        
        device.name = "Anders"  // **************
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
        //self.AccelerometerGraphView.fullScale = 2
        accelerometerBMI160.sampleFrequency = 50
    }
    
    func updateGyroBMI160Settings() {
        
        let gyroBMI160 = self.device.gyro as! MBLGyroBMI160
        gyroBMI160.fullScaleRange = .range500
        //self.gyroBMI160Graph.fullScale = 4
        gyroBMI160.sampleFrequency = 50
        
    }
    
    func updateLightSettings(){
    
        let ambientLightLTR329 = device.ambientLight as! MBLAmbientLightLTR329
        ambientLightLTR329.gain = .gain1X
        ambientLightLTR329.integrationTime = .integration50ms
        ambientLightLTR329.measurementRate = .rate2000ms
        lightEvent = ambientLightLTR329.periodicIlluminance
        
    }
    
    func clearDataArrays(){
    
        lightData.removeAll()
        humidityData.removeAll()
        temperatureData.removeAll()
        gyroBMI160Data.removeAll()
        accelerometerBMI160Data.removeAll()
        
    }
    
    func logCleanup(_ handler: @escaping MBLErrorHandler) {
        // In order for the device to actaully erase the flash memory we can't be in a connection
        // so temporally disconnect to allow flash to erase.
        isObserving = false
        device.disconnectAsync().continueOnDispatch { t in
            self.isObserving = true
            guard t.error == nil else {
                return t
            }
            return self.device.connect(withTimeoutAsync: 15)
            }.continueOnDispatch { t in
                handler(t.error)
                return nil
        }
    }
    
    
    //**********************************************************
    //                   TRACKING FUNCTIONS
    //**********************************************************
    
    @IBAction func StartMonitoring(_ sender: Any) {
        
        print("Start Monitoring tapped")
        
        StartMonitoringButton.isEnabled = false
        StopMonitoringButton.isEnabled = true
        device.led?.flashColorAsync(UIColor.magenta, withIntensity: 1.0)
        
      
            
        // ----- Movement -----
        updateAccelerometerBMI160Settings()
        device.accelerometer!.dataReadyEvent.startLoggingAsync()
        
        updateGyroBMI160Settings()
        device.gyro!.dataReadyEvent.startLoggingAsync()
 
        // ----- Crying -----
        
        
        
        // ----- Ambient -----
        temperatureEvent = device.temperature!.onboardThermistor?.periodicRead(withPeriod: 60000)
        temperatureEvent.startLoggingAsync()
        
        humidityEvent = device.hygrometer!.humidity!.periodicRead(withPeriod: 60000)
        humidityEvent.startLoggingAsync()
        
        updateLightSettings()
        lightEvent.startLoggingAsync()

    }
    
    @IBAction func StopMonitoring(_ sender: Any) {
        print("Stop Monitoring tapped")
            
        StartMonitoringButton.isEnabled = true
        StopMonitoringButton.isEnabled = false
        device.led?.setLEDOnAsync(false, withOptions: 1)
       
        
        // ----- Movement -----
        device.accelerometer!.dataReadyEvent.downloadLogAndStopLoggingAsync(true, progressHandler: { number in
        }).success({ array in self.accelerometerBMI160Data = array as! [MBLAccelerometerData]
            print("ACCELEROMETER DATA:")
            // array contains all the log entries
            for obj in self.accelerometerBMI160Data {
                print("Entry: " + String(describing: obj))
                //self.AccelerometerGraphView.addX(obj.x, y: obj.y, z: obj.z)
            }
            self.count += 1
            self.checkCount()
        })

        device.gyro!.dataReadyEvent.downloadLogAndStopLoggingAsync(true, progressHandler: { number in
        }).success({ array in self.gyroBMI160Data = array as! [MBLGyroData]
            print("GYROSCOPE DATA:")
            // array contains all the log entries
            for obj in self.gyroBMI160Data {
                print("Entry: " + String(describing: obj))
            }
            self.count += 1
            self.checkCount()
        })
        
        
        
        // ----- Crying -----
        
        
        // ----- Ambient -----
        
        temperatureEvent.downloadLogAndStopLoggingAsync(true, progressHandler: { number in
        }).success({ array in self.temperatureData = array as! [MBLNumericData]
            print("TEMPERATURE DATA:")
            // array contains all the log entries
            for obj in self.temperatureData {
                print("Entry: " + String(describing: obj))
            }
            self.count += 1
            self.checkCount()
        })
        
        humidityEvent.downloadLogAndStopLoggingAsync(true, progressHandler: { number in
        }).success({ array in self.humidityData = array as! [MBLNumericData]
            print("HUMIDITY DATA:")
            // array contains all the log entries
            for obj in self.humidityData {
                print("Entry: " + String(describing: obj))
            }
            self.count += 1
            self.checkCount()
        })
        
        lightEvent.downloadLogAndStopLoggingAsync(true, progressHandler: { number in
        }).success({ array in self.lightData = array as! [MBLNumericData]
            print("LIGHT DATA:")
            // array contains all the log entries
            for obj in self.lightData {
                print("Entry: " + String(describing: obj))
            }
            self.count += 1
            self.checkCount()
        })
        
        self.logCleanup{ error in
            if error != nil {
                print("hmmmm.... can`t clear the log.")
            }
        }
    }
    
    
    func checkCount(){
        if(count == 5){
           performSegue(withIdentifier: "graphSegue", sender: self)
            print("count = 5")
        }
    
    }
    
    @IBAction func StartStreaming(_ sender: Any) {
        print("Start Streaming tapped")
        
        StartStreamingButton.isEnabled = false
        StopStreamingButton.isEnabled = true
        device.led?.setLEDColorAsync(UIColor.cyan, withIntensity: 1.0)
        
        // ----- Movement -----
        updateAccelerometerBMI160Settings()
        var array_A = [MBLAccelerometerData]() /* capacity: 1000 */
        accelerometerBMI160Data = array_A
        streamingEvents.insert(device.accelerometer!.dataReadyEvent)
        device.accelerometer!.dataReadyEvent.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                //self.AccelerometerGraphView.addX(obj.x, y: obj.y, z: obj.z)
                array_A.append(obj)
                //print("x: ", obj.x, ", y: ", obj.y, ", z: ", obj.z)
            }
        }
        
        
        
        // ----- Crying -----
        
        // ----- Ambient -----
        
        
    }
    
    @IBAction func StopStreaming(_ sender: Any) {
        print("Stop Streaming tapped")
        
        StartStreamingButton.isEnabled = true
        StopStreamingButton.isEnabled = false
        device.led?.setLEDOnAsync(false, withOptions: 1)
        
        // ----- Movement -----
        streamingEvents.remove(device.accelerometer!.dataReadyEvent)
        device.accelerometer!.dataReadyEvent.stopNotificationsAsync()
        
        
        // ----- Crying -----
        
        
        // ----- Ambient -----
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "graphSegue") {
            if let DVC = segue.destination as? GraphController{
                DVC.accelerometerArray = accelerometerBMI160Data
                DVC.gyroscopeArray = gyroBMI160Data
                DVC.lightArray = lightData
                DVC.humidityArray = humidityData
                DVC.temperatureArray = temperatureData
                
            } else {
                print("Data NOT Passed! destination vc is not set to firstVC")
            }
            print("id matched")
        } else {
            print("Id doesnt match with Storyboard segue Id")
        }
        
    }
    
}
