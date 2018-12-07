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
    var time: Date
    var isFavorite: Bool
    var peripheralDevice: CBPeripheral
    var rssi: NSNumber
    var turnNeedleCharacteristic: CBCharacteristic?
    var serialString: String?
    
    init(peripheral: CBPeripheral, rssi: NSNumber, time: Date = Date(), isFavorite: Bool = false) {
        self.peripheralDevice = peripheral
        self.isFavorite = isFavorite
        self.time = time
        self.rssi = rssi
    }
}
