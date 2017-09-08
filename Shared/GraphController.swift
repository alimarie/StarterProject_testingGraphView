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
    
    @IBOutlet weak var textView: UITextView!
    
    var accelerometerArray = [MBLAccelerometerData]()
    var gyroscopeArray = [MBLGyroData]()
    var cryingArray = [MBLNumericData]()
    var feedingArray = [MBLNumericData]()
    var lightArray = [MBLNumericData]()
    var humidityArray = [MBLNumericData]()
    var temperatureArray = [MBLNumericData]()
    
    override func viewDidLoad() {
        print("graph view did load")
        
        if(accelerometerArray.count != 0){
            print(accelerometerArray)
        }
        else{
            print("empty still")
        }

        
    }
    
    

    
    
    
}
