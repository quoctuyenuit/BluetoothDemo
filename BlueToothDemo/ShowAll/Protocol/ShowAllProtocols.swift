//
//  ShowAllProtocols.swift
//  BlueToothDemo
//
//  Created by Mr Tuyen Nguyen Quoc Tuyen on 12/3/18.
//  Copyright © 2018 Mr Tuyen Nguyen Quoc Tuyen. All rights reserved.
//

import Foundation
import UIKit

protocol ShowAllViewProtocol {
    var presenter: ShowAllPresenterProtocol? { get set }
}
protocol ShowAllPresenterProtocol {
    var view: ShowAllViewProtocol? { get set }
    var interactor: ShowAllInteractorProtocol? { get set }
    var router: ShowAllRouterProtocol? { get set }
    
    func showDetailPeripheralDevice(from viewController: UIViewController, item: PeripheralDevice) -> ShowAllViewDelegate?
}
protocol ShowAllInteractorProtocol {
    
}
protocol ShowAllRouterProtocol {
    static func createShowAllViewController() -> UIViewController
    func showDetailPeripheralDevice(from viewController: UIViewController, item: PeripheralDevice) -> ShowAllViewDelegate?
}
