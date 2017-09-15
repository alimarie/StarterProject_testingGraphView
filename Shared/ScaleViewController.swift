//
//  ScaleViewController.swift
//
//  Created by Ali Wood on 04/09/2017.
//  Copyright © 2017 Ali Wood. All rights reserved.
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
    
    // daily intake variables
    var dailyTotal = 0
    var feedingData = [[(NSDate, Int)]]()     // [date] [measurement]
    @IBOutlet weak var dailyTotalLabel: UILabel!
    
    // individual feeding variables
    var feedingTotal = 0
    var preFeeding = 0
    var postFeeding = 0
    @IBOutlet weak var lastFeedingLabel: UILabel!
    
    // current measurement variables
    var heldWeight = 0
    var hw1 = 1
    var hw2 = 2
    var hw3 = 3
    
    let BLEService = "1804"
    let BLECharacteristic = "2A07"
    
    
    var peripherals:[CBPeripheral] = []
    
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
    
    
    // MARK: Button Methods
    func scanButtonPressed() {
        scanBLEDevices()
    }
    
    func disconnectButtonPressed() {
        //this will call didDisconnectPeripheral, but if any other apps are using the device it will not immediately disconnect
        manager?.cancelPeripheralConnection(mainPeripheral!)
    }
    
    
    // MARK: - CBCentralManagerDelegate Methods 
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(!peripherals.contains(peripheral)) {
            peripherals.append(peripheral)
        }
        
        manager?.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        //pass reference to connected peripheral to parent view
        mainPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
        //set the manager's delegate view to parent so it can call relevant disconnect methods
        manager?.delegate = self
        customiseNavigationBar()

        print("Connected to " +  peripheral.name!)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        mainPeripheral = nil
        customiseNavigationBar()
        print("Disconnected " + peripheral.name!)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
    }
    
    
    // MARK: CBPeripheralDelegate Methods
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        for service in peripheral.services! {
            
            //print("Service found with UUID: " + service.uuid.uuidString)
            
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
            for characteristic in service.characteristics! {
                peripheral.setNotifyValue(true, for: characteristic)
                if (characteristic.uuid.uuidString == "0000FA01-494C-4F47-4943-544543480000") {
                    peripheral.readValue(for: characteristic)
                    //print("Found Characteristic 1")
                }
                if (characteristic.uuid.uuidString == "0000FA02-494C-4F47-4943-544543480000") {
                    peripheral.readValue(for: characteristic)
                    //print("Found Characteristic 2")
                }
                if (characteristic.uuid.uuidString == "0000FA03-494C-4F47-4943-544543480000") {
                    peripheral.readValue(for: characteristic)
                    //print("Found Characteristic 3")
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
                
                // cleaning up value to grab only the weight characters
                var shortStringValue = stringValue.characters.suffix(6)
                shortStringValue.removeLast()
                
                print("stringValue: ", stringValue)
                print("shortStringValue: ", String(shortStringValue))
                print("heldWeight: ", String(describing: heldWeight))
                
                let measurement = Int(String(shortStringValue))
                
                if(holdMeasurement(value: measurement!)) {
                    heldWeight = measurement!
                }
                
            }
            
        }
        
    }
    
    
    // ********** FROM SCAN TABLE VIEW CONTROLLER **********
    func scanBLEDevices() {
        manager?.scanForPeripherals(withServices: [CBUUID.init(string: BLEService)], options: nil)
        
        //stop scanning after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.stopScanForBLEDevices()
        }
        
        // print("Connected to " +  (mainPeripheral?.name)!)
    }
    
    func stopScanForBLEDevices() {
        manager?.stopScan()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "return from scale") {
            manager?.cancelPeripheralConnection(mainPeripheral!)
        }
        
    }
    
    
    // ********** MEASUREMENT METHODS **********
    
    /*
     *      holdMeasurement
     *
     *      Reads the current value output by the scale and returns true once the
     *      value is "held" (aka. the value no longer changes)
     */
    func holdMeasurement(value: Int) -> Bool {
        
        hw3 = hw2
        hw2 = hw1
        hw1 = value
        
        if(hw1 == hw2 && hw2 == hw3){
            return true
        } else {
            return false
        }
    
    }
    
    
    /*
     *      getCurrentMeasurement
     */
    func getCurrentMeasurement() -> Int {
        
        // wait 30 seconds to make sure value held**
        
        // grab current held weight
        return heldWeight
        
    }
    
    
    /*
     *      calculateCurrentFeedingTotal
     *
     *      compares values before and after feeding to calculate the total food intake.  
     *      If a valid measurement is taken, preFeeding and postFeeding values are reset.
     */
    func calculateCurrentFeedingTotal() -> Int {
        
        let feeding = postFeeding - preFeeding
        if (feeding > 0){
            preFeeding = -1
            postFeeding = -1
            print("Total amount in this feeding: ", String(feedingTotal))
            return feeding
        }
        else {
            print("Incorrect measurement.")
            return 0
        }
        
    }

    /*
     *      calculateDailyFeedingTotal
     *
     *      Keeps track of daily food intake.  Checks the current time, and if the date
     *      does not match the last feeding, saves value into new cell in array.
    */
    func calculateDailyFeedingTotal( lastFeeding: Int ) {
        dailyTotal += lastFeeding
        
        feedingData.append([(Date() as NSDate, dailyTotal)])
        
        print("Total Daily Food Intake: ", feedingData.last!)
        
    }

    @IBAction func StartFeeding(_ sender: Any) {
        
        var value = getCurrentMeasurement()
        value = preFeeding
        
    }
    
    @IBAction func StopFeeding(_ sender: Any) {
        
        // get post-feeding measurement
        postFeeding = getCurrentMeasurement()
        
        // calculate the last feeding
        feedingTotal = calculateCurrentFeedingTotal()
        self.lastFeedingLabel.text = String(feedingTotal)
        
        // calculate the daily total 
        calculateDailyFeedingTotal(lastFeeding: feedingTotal)
        self.dailyTotalLabel.text = String(dailyTotal)
        
        print("check labels for update")
    }
    
    
}

