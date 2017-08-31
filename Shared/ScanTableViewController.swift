//
//  ScanTableViewController.swift
//
//  Created by Stephen Schiffli on 8/14/15.
//  Copyright (c) 2015 MbientLab Inc. All rights reserved.
//

import UIKit
import MetaWear
import MBProgressHUD
// TESTING SCALE ADD IN *******
import CoreBluetooth
// ****************************

protocol ScanTableViewControllerDelegate {
    func scanTableViewController(_ controller: ScanTableViewController, didSelectDevice device: MBLMetaWear)
}

//class ScanTableViewController: UITableViewController
class ScanTableViewController: UITableViewController, CBPeripheralDelegate  {
    var delegate: ScanTableViewControllerDelegate?
    var devices: [MBLMetaWear]?
    var selected: MBLMetaWear?
    
    // TESTING SCALE ADD IN *******
    var manager = MBLMetaWearManager.shared()
    var manager2:CBCentralManager? = nil
    let BLEService = "1804"
    // ****************************
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        MBLMetaWearManager.shared().startScan(forMetaWearsAllowDuplicates: true) { array in
            self.devices = array
            self.tableView.reloadData()
        }
        
        //  TESTING SCALE ADD_IN *********
        manager2?.scanForPeripherals(withServices: [CBUUID.init(string: BLEService)], options: nil)
        // *******************************
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        MBLMetaWearManager.shared().stopScan()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MetaWearCell", for: indexPath) 

        // Configure the cell...
        if let cur = devices?[(indexPath as NSIndexPath).row] {
            let uuid = cell.viewWithTag(1) as! UILabel
            uuid.text = cur.identifier.uuidString
            
            let connected = cell.viewWithTag(3) as! UILabel
            if cur.state == .connected {
                connected.isHidden = false
            } else {
                connected.isHidden = true
            }
            
            let name = cell.viewWithTag(4) as! UILabel
            name.text = cur.name
            
            let rssi = cell.viewWithTag(2) as! UILabel
            let signal = cell.viewWithTag(5) as! UIImageView
            if let movingAverage = cur.averageRSSI?.doubleValue {
                rssi.isHidden = false
                rssi.text = cur.discoveryTimeRSSI?.stringValue ?? ""
                
                if movingAverage < -80.0 {
                    signal.image = UIImage(named: "wifi_d1")
                } else if movingAverage < -70.0 {
                    signal.image = UIImage(named: "wifi_d2")
                } else if movingAverage < -60.0 {
                    signal.image = UIImage(named: "wifi_d3")
                } else if movingAverage < -50.0 {
                    signal.image = UIImage(named: "wifi_d4")
                } else if movingAverage < -40.0 {
                    signal.image = UIImage(named: "wifi_d5")
                } else {
                    signal.image = UIImage(named: "wifi_d6")
                }
            } else {
                signal.image = UIImage(named: "wifi_not_connected")
                rssi.isHidden = true
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let selected = devices?[(indexPath as NSIndexPath).row] {
            let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
            hud.label.text = "Connecting..."
            
            self.selected = selected
            selected.connect(withTimeoutAsync: 15).success { _ in
                hud.hide(animated: true)
                selected.led?.flashColorAsync(UIColor.green, withIntensity: 1.0)
                
                let alert = UIAlertController(title: "Confirm Device", message: "Do you see a blinking green LED on the MetaWear", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction) -> Void in
                    selected.led?.setLEDOnAsync(false, withOptions: 1)
                    selected.disconnectAsync()
                }))
                alert.addAction(UIAlertAction(title: "Yes!", style: .default, handler: { (action: UIAlertAction) -> Void in
                    selected.led?.setLEDOnAsync(false, withOptions: 1)
                    selected.disconnectAsync()
                    if let delegate = self.delegate {
                        delegate.scanTableViewController(self, didSelectDevice: selected)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            }.failure { error in
                hud.label.text = error.localizedDescription
                hud.hide(animated: true, afterDelay: 2.0)
            }
        }
    }
    
    // ************* BLE imported functions *************
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
    // *************************************************
    
}
