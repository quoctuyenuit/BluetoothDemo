//
//  ShowDetailProtocol.swift
//  BlueToothDemo
//
//  Created by Mr Tuyen Nguyen Quoc Tuyen on 12/4/18.
//  Copyright © 2018 Mr Tuyen Nguyen Quoc Tuyen. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

protocol ShowDetailViewProtocol {
    var presenter: ShowDetailPresenterProtocol? { get set }
}
protocol ShowDetailPresenterProtocol {
    var view: ShowDetailViewProtocol? { get set }
    var interactor: ShowDetailInteractorProtocol? { get set }
    var router: ShowDetailRouterProtocol? { get set }
    
    func writeCommandSample(to peripheralDevice: CBPeripheral, for characteristic: CBCharacteristic)
}
protocol ShowDetailInteractorProtocol {
    func writeCommandSample(to peripheralDevice: CBPeripheral, for characteristic: CBCharacteristic)
}
protocol ShowDetailRouterProtocol {
    static func createShowDetailViewController(for model: PeripheralDevice) -> UIViewController
}
