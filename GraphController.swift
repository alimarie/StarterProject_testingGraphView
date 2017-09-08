//
//  GraphViewController.swift
//  StarterProject
//
//  Created by AliWood on 9/8/17.
//  Copyright © 2017 MBIENTLAB, INC. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import MetaWear

class GraphController {
    
    
    // GRAPH VIEWS
    @IBOutlet weak var AccelerometerGraphView: APLGraphView!
    @IBOutlet weak var GyroscopeGraphView: APLGraphView!
    @IBOutlet weak var CryingGraphView: APLGraphView!
    @IBOutlet weak var FeedingGraphView: APLGraphView!
    @IBOutlet weak var LightGraphView: APLGraphView!
    @IBOutlet weak var HumidityGraphView: APLGraphView!
    @IBOutlet weak var TemperatureGraphView: APLGraphView!
    
    var arrayWithoutData = [MBLAccelerometerData]()
    
    func viewDidLoad() {
        print("graph view did load")
        

        
    }
    
    

    
    
    
}
