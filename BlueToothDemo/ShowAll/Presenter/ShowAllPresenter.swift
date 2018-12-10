//
//  ShowAllPresenter.swift
//  BlueToothDemo
//
//  Created by Mr Tuyen Nguyen Quoc Tuyen on 12/3/18.
//  Copyright © 2018 Mr Tuyen Nguyen Quoc Tuyen. All rights reserved.
//

import Foundation
import UIKit

class ShowAllPresenter: ShowAllPresenterProtocol {
    var view: ShowAllViewProtocol?
    var interactor: ShowAllInteractorProtocol?
    var router: ShowAllRouterProtocol?
    
    func showDetailPeripheralDevice(from viewController: UIViewController, item: PeripheralDevice) -> ShowAllViewDelegate? {
        return self.router?.showDetailPeripheralDevice(from: viewController, item: item)
    }
}
