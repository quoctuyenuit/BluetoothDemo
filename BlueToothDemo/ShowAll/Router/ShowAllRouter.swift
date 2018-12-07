//
//  ShowAllRouter.swift
//  BlueToothDemo
//
//  Created by Mr Tuyen Nguyen Quoc Tuyen on 12/3/18.
//  Copyright © 2018 Mr Tuyen Nguyen Quoc Tuyen. All rights reserved.
//

import Foundation
import UIKit

class ShowAllRouter: ShowAllRouterProtocol {
    static func createShowAllViewController() -> UIViewController {
        var view: UIViewController & ShowAllViewProtocol = ShowAllViewController()
        var presenter: ShowAllPresenterProtocol = ShowAllPresenter()
        let interactor: ShowAllInteractorProtocol = ShowAllInteractor()
        let router: ShowAllRouterProtocol = ShowAllRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        return UINavigationController(rootViewController: view)
    }
  
    func showDeviceInformationDetail(from viewController: UIViewController, item: PeripheralDevice) -> ShowAllViewDelegate? {
        let detailViewController = ShowDetailRouter.createShowDetailViewController(for: item)
        let showDetailViewController = detailViewController as? ShowDetailViewController
        showDetailViewController?.delegate  = viewController as? ShowDetailViewDelegate
        
        viewController.navigationController?.pushViewController(detailViewController, animated: true)
        return detailViewController as? ShowAllViewDelegate
    }
}
