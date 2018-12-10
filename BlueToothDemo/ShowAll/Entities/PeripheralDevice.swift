//
//  PeripheralDevice.swift
//  BlueToothDemo
//
//  Created by Mr Tuyen Nguyen Quoc Tuyen on 12/3/18.
//  Copyright © 2018 Mr Tuyen Nguyen Quoc Tuyen. All rights reserved.
//

import Foundation
import CoreBluetooth

class PeripheralDevice {
    var isFavorite: Bool
    var peripheralDevice: CBPeripheral
    var rssi: NSNumber
    var serialString: String
    
    init(peripheral: CBPeripheral, rssi: NSNumber, serial: String = "Unknown", isFavorite: Bool = false) {
        self.peripheralDevice = peripheral
        self.isFavorite = isFavorite
        self.rssi = rssi
        self.serialString = serial
    }
}
