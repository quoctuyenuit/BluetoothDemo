//
//  ShowDetailRouter.swift
//  BlueToothDemo
//
//  Created by Mr Tuyen Nguyen Quoc Tuyen on 12/5/18.
//  Copyright © 2018 Mr Tuyen Nguyen Quoc Tuyen. All rights reserved.
//

import Foundation
import UIKit

class ShowDetailRouter: ShowDetailRouterProtocol {
    static func createShowDetailViewController(for model: PeripheralDevice) -> UIViewController {
        var view: UIViewController & ShowDetailViewProtocol = ShowDetailViewController(for: model)
        var presenter: ShowDetailPresenterProtocol = ShowDetailPresenter()
        let interactor: ShowDetailInteractorProtocol = ShowDetailInteractor()
        let router: ShowDetailRouterProtocol = ShowDetailRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        return view
    }
}
