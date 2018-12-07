//
//  ShowDetailInteractor.swift
//  BlueToothDemo
//
//  Created by Mr Tuyen Nguyen Quoc Tuyen on 12/5/18.
//  Copyright © 2018 Mr Tuyen Nguyen Quoc Tuyen. All rights reserved.
//

import Foundation
import CoreBluetooth

class ShowDetailInteractor: ShowDetailInteractorProtocol {
    func writeCommandSample(to peripheralDevice: CBPeripheral, for characteristic: CBCharacteristic) {
        guard let data = "02f105".dataFromHexadecimal() else { return }
        peripheralDevice.writeValue(data as Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
    }
}


extension String {
    func dataFromHexadecimal() -> Data? {
        guard self.count % 2 == 0 else {
            return nil
        }
        
        var data = Data(capacity: self.count / 2)
        let range = NSRange.init(location: 0, length: utf16.count)
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        
        regex.enumerateMatches(in: self, range: range) { match, _,_ in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        
        guard data.count > 0 else {
            return nil
        }
        
        return data
    }
}
