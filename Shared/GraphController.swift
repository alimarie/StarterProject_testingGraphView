//
//  GraphViewController.swift
//  StarterProject
//
//  Created by AliWood on 9/8/17.
//  Copyright © 2017 MBIENTLAB, INC. All rights reserved.
//

//import Foundation
import UIKit
//import CoreBluetooth
import MetaWear

class GraphController: UIViewController {
    
    
    // GRAPH VIEWS
    @IBOutlet weak var AccelerometerGraphView: APLGraphView!
    @IBOutlet weak var GyroscopeGraphView: APLGraphView!
    @IBOutlet weak var CryingGraphView: APLGraphView!
    @IBOutlet weak var FeedingGraphView: APLGraphView!
    @IBOutlet weak var LightGraphView: APLGraphView!
    @IBOutlet weak var HumidityGraphView: APLGraphView!
    @IBOutlet weak var TemperatureGraphView: APLGraphView!
    
    
    var accelerometerArray = [MBLAccelerometerData]()
    var gyroscopeArray = [MBLGyroData]()
    var cryingArray = [MBLNumericData]()
    var feedingArray = [MBLNumericData]()
    var lightArray = [MBLNumericData]()
    var humidityArray = [MBLNumericData]()
    var temperatureArray = [MBLNumericData]()
    
    override func viewDidLoad() {
        
        defineGraphViewSettings()
        if(accelerometerArray.count != 0){
            for obj in self.accelerometerArray {
                self.AccelerometerGraphView.addX(obj.x, y: obj.y, z: obj.z)
            }
            for obj in self.gyroscopeArray {
                self.GyroscopeGraphView.addX(obj.z, y: obj.z, z: obj.z)
            }
            for obj in self.lightArray {
                let val = Double(obj.value)
                self.LightGraphView.addX(val, y: val, z: val)
            }
            for obj in self.humidityArray {
                let val = Double(obj.value)
                self.HumidityGraphView.addX(val, y: val, z: val)
            }
            for obj in self.temperatureArray {
                let val = Double(obj.value)
                self.TemperatureGraphView.addX(val, y: val, z: val)
            }
        }
            
        else{
            print("empty still")
        }
        
    }
    
    func defineGraphViewSettings() {
    
        self.AccelerometerGraphView.fullScale = 2
        self.GyroscopeGraphView.fullScale = 4
        self.LightGraphView.fullScale = 400
        self.HumidityGraphView.fullScale = 100
        self.TemperatureGraphView.fullScale = 60
    
    }
    

    
    
    
}
