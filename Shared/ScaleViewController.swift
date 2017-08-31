//
//  ScaleViewController.swift
//  CompassCompanion
//
//  Created by Rick Smith on 04/07/2016.
//  Copyright © 2016 Rick Smith. All rights reserved.
//

import UIKit
import CoreBluetooth

/*
 SERVICES -
 #define WITTRAVELLER_IMMEDIATE_ALLERT_SERVICE_UUID @"1802"     --- DISCOVERABLE W/ 2A06 - *no notified value
 #define WITTRAVELLER_LINK_LOSS_SERVICE_UUID @"1803"            --- DISCOVERABLE W/ 2A06
 #define WITTRAVELLER_TX_POWER_SERVICE_UUID @"1804"             --- DISCOVERABLE W/ 2A07
 #define WITTRAVELLER_DEVICE_INFO_SERVICE_UUID @"180A"
 
 CHARACTERISTICS -
 #define WITTRAVELLER_TX_POWER_CHARACTERISTIC_UUID @"2A07"      --- DISCOVERABLE W/ 1804
 #define WITTRAVELLER_ALERT_LEVEL_CHARACTERISTIC_UUID @"2A06"   --- DISCOVERABLE W/ 1802*, 1803         
 #define WITTRAVELLER_MANUFACTURER_NAME_CHARACTERISTIC_UUID @"2A29"
 */

class ScaleViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var manager:CBCentralManager? = nil
    var mainPeripheral:CBPeripheral? = nil
    var mainCharacteristic:CBCharacteristic? = nil
    
    let BLEService = "1804"
    let BLECharacteristic = "2A07"
    
    @IBOutlet weak var recievedMessageText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CBCentralManager(delegate: self, queue: nil);
        
        customiseNavigationBar()
    }
    
    func customiseNavigationBar () {
        
        self.navigationItem.rightBarButtonItem = nil
        
        let rightButton = UIButton()
        
        if (mainPeripheral == nil) {
            rightButton.setTitle("Scan", for: [])
            rightButton.setTitleColor(UIColor.blue, for: [])
            rightButton.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 60, height: 30))
            rightButton.addTarget(self, action: #selector(self.scanButtonPressed), for: .touchUpInside)
        } else {
            rightButton.setTitle("Disconnect", for: [])
            rightButton.setTitleColor(UIColor.blue, for: [])
            rightButton.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 100, height: 30))
            rightButton.addTarget(self, action: #selector(self.disconnectButtonPressed), for: .touchUpInside)
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = rightButton
        self.navigationItem.rightBarButtonItem = rightBarButton
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "scan-segue") {
            let scanController : ScanTableViewController = segue.destination as! ScanTableViewController
            
            //set the manager's delegate to the scan view so it can call relevant connection methods
            manager?.delegate = scanController
            scanController.manager = manager
            scanTab.parentView = self
        }
        
    }
    
    // MARK: Button Methods
    func scanButtonPressed() {
        performSegue(withIdentifier: "scan-segue", sender: nil)
    }
    
    func disconnectButtonPressed() {
        //this will call didDisconnectPeripheral, but if any other apps are using the device it will not immediately disconnect
        manager?.cancelPeripheralConnection(mainPeripheral!)
    }
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        let helloWorld = "Hello World!"
        let dataToSend = helloWorld.data(using: String.Encoding.utf8)
        
        if (mainPeripheral != nil) {
            mainPeripheral?.writeValue(dataToSend!, for: mainCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
        } else {
            print("haven't discovered device yet")
        }
    }
    
    // MARK: - CBCentralManagerDelegate Methods    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        mainPeripheral = nil
        customiseNavigationBar()
        print("Disconnected" + peripheral.name!)
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
    }
    
    // MARK: CBPeripheralDelegate Methods
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        for service in peripheral.services! {
            
            print("Service found with UUID: " + service.uuid.uuidString)
         
            if (service.uuid.uuidString == "1804") {
                peripheral.discoverCharacteristics(nil, for: service)
            }
       
            if (service.uuid.uuidString == "0000FA00-494C-4F47-4943-544543480000") {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        if (service.uuid.uuidString == "0000FA00-494C-4F47-4943-544543480000") {
                print("Found 0000FA00-494C-4F47-4943-544543480000 service!!")
            for characteristic in service.characteristics! {
                peripheral.setNotifyValue(true, for: characteristic)
                if (characteristic.uuid.uuidString == "0000FA01-494C-4F47-4943-544543480000") {
                    peripheral.readValue(for: characteristic)
                    print("Found Characteristic 1")
                }
                if (characteristic.uuid.uuidString == "0000FA02-494C-4F47-4943-544543480000") {
                    peripheral.readValue(for: characteristic)
                    print("Found Characteristic 2")
                }
                if (characteristic.uuid.uuidString == "0000FA03-494C-4F47-4943-544543480000") {
                    peripheral.readValue(for: characteristic)
                    print("Found Characteristic 3")
                }
                
            }
            
        }
        
        
        
        if (service.uuid.uuidString == BLEService) {
            
            for characteristic in service.characteristics! {
                
                if (characteristic.uuid.uuidString == BLECharacteristic) {
                    //we'll save the reference, we need it to write data
                    mainCharacteristic = characteristic
                    
                    //Set Notify is useful to read incoming data async
                    peripheral.setNotifyValue(true, for: characteristic)
                    print("Found BLE service and Characteristic (TX power)")
                }
                
            }
            
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        
        if (characteristic.uuid.uuidString == "0000FA01-494C-4F47-4943-544543480000") {
            //value for device name recieved
           let weight = characteristic.value
            print(weight ?? "No Weight")
             
            if(characteristic.value != nil){
                let stringValue = String(data: characteristic.value!, encoding: String.Encoding.utf8)!
                print("1 - uft8: ", stringValue)
            }
        }
      
        
        

        
    }
    
}

