//
//  ShowDetailPresenter.swift
//  BlueToothDemo
//
//  Created by Mr Tuyen Nguyen Quoc Tuyen on 12/4/18.
//  Copyright © 2018 Mr Tuyen Nguyen Quoc Tuyen. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class ShowDetailPresenter: ShowDetailPresenterProtocol {
    var view: ShowDetailViewProtocol?
    var router: ShowDetailRouterProtocol?
    var interactor: ShowDetailInteractorProtocol?
    
    func writeCommandSample(to peripheralDevice: CBPeripheral, for characteristic: CBCharacteristic) {
        self.interactor?.writeCommandSample(to: peripheralDevice, for: characteristic)
    }
}
