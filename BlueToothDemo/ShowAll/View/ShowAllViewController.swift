//
//  ShowAllViewController.swift
//  BlueToothDemo
//
//  Created by Mr Tuyen Nguyen Quoc Tuyen on 12/3/18.
//  Copyright © 2018 Mr Tuyen Nguyen Quoc Tuyen. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import ExternalAccessory


/*
 description
 
 - listItems: List of all item in table view
 
 - listFavorite: List of favorite item
 
 - isFilterFavorite: The flag to determine whether or not filter according favorite
 
 - SHINE_MISFIT_SERVICE_BUUID: Properties to filter service of shine device
 
 
 /
 */
protocol ShowAllViewDelegate {
    func showAllView(didChangeStatus status: CBPeripheralState)
}

class ShowAllViewController: UIViewController, ShowAllViewProtocol {
    
    //MARK: - Common properties
    var presenter: ShowAllPresenterProtocol?
    private var _centralManager: CBCentralManager!
    private final let _reuseIdentifier = "ShowAllReuseIdentifier"
    
    
    let kSHINE_MISFIT_SERVICE_BUUID = CBUUID(nsuuid: UUID(uuidString: "3dda0001-957f-7d4a-34a6-74696673696d")!)
    let kDEVICE_INFORMATION_SERVICE_CBUUID = CBUUID(string: "0x180A")
    let kHEART_RATE_SERVICE_CBUUID = CBUUID(string: "0x180D")

    
    private var _listDisconnectedItems = [PeripheralDevice]()
    private var _listFavoriteDisconnectedItems = [PeripheralDevice]()
    private var _listConnectedItems = [PeripheralDevice]()
    private var _listFavoriteConnectedItems = [PeripheralDevice]()
    
    public var delegate: ShowAllViewDelegate?
    
    private var _isFilterFavorite: Bool = false {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private var _isSorted: Bool = false {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    //MARK: - View properties
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.register(TableViewCell.self, forCellReuseIdentifier: self._reuseIdentifier)
        table.delegate = self
        table.dataSource = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 50
        return table
    }()
    
    private lazy var favoriteFilterButton: UIBarButtonItem = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ico_rating_checked"), for: .normal)
        btn.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    private lazy var sortButton: UIBarButtonItem = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ico_sort"), for: .normal)
        btn.addTarget(self, action: #selector(sortTapped(_:)), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    private lazy var refreshButton: UIBarButtonItem = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ico_refresh"), for: .normal)
        btn.addTarget(self, action: #selector(refreshTapped(_:)), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    //MARK: - Setup view function
    private func setupView() {
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.navigationItem.leftBarButtonItems = [self.favoriteFilterButton,self.refreshButton]
        self.navigationItem.rightBarButtonItems = [self.sortButton]
    }
    
    @objc private func filterTapped(_ sender: UIButton) {
        self._listFavoriteDisconnectedItems.removeAll()
        self._listDisconnectedItems.forEach {
            if $0.isFavorite {
                self._listFavoriteDisconnectedItems.append($0)
            }
        }
        self._isFilterFavorite = !self._isFilterFavorite
    }
    
    @objc private func refreshTapped(_ sender: UIButton) {
        self.refreshData()
    }
    
    private func refreshData() {
        self.retrieveConnectedDevice()
        self._listDisconnectedItems.removeAll()
        self._listFavoriteDisconnectedItems.removeAll()
        self.tableView.reloadData()
        self._centralManager.stopScan()
        self._centralManager.scanForPeripherals(withServices: [kDEVICE_INFORMATION_SERVICE_CBUUID, kHEART_RATE_SERVICE_CBUUID, kSHINE_MISFIT_SERVICE_BUUID])
    }
    
    @objc private func sortTapped(_ sender: UIButton) {
        self._isSorted = !self._isSorted
        if self._isSorted {
            if !self._isFilterFavorite {
                _listDisconnectedItems = _listDisconnectedItems.sorted(by: { $0.rssi.compare($1.rssi) == .orderedAscending })
            } else {
                _listFavoriteDisconnectedItems = _listFavoriteDisconnectedItems.sorted(by: { $0.rssi.compare($1.rssi) == .orderedAscending })
            }
        } else {
            if !self._isFilterFavorite {
                _listDisconnectedItems = _listDisconnectedItems.sorted(by: { $0.rssi.compare($1.rssi) == .orderedDescending })
            } else {
                _listFavoriteDisconnectedItems = _listFavoriteDisconnectedItems.sorted(by: { $0.rssi.compare($1.rssi) == .orderedDescending })
            }
        }
    }
    
    //MARK: - Override function
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self._centralManager = CBCentralManager(delegate: self, queue: nil)
        self.retrieveConnectedDevice()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshData()
    }
    
    private func retrieveConnectedDevice() {
        self._listConnectedItems.removeAll()
        
        self._centralManager.retrieveConnectedPeripherals(withServices: [kDEVICE_INFORMATION_SERVICE_CBUUID, kHEART_RATE_SERVICE_CBUUID, kSHINE_MISFIT_SERVICE_BUUID]).forEach { (peripheral) in
            let device = PeripheralDevice(peripheral: peripheral, rssi: NSNumber(value: 0))
            self._listConnectedItems.append(device)
        }
    }
}

extension ShowAllViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section
        var model: PeripheralDevice
        if section == 0 {
            model = self._isFilterFavorite ? self._listFavoriteConnectedItems[indexPath.row] : self._listConnectedItems[indexPath.row]
        } else {
            model = self._isFilterFavorite ? self._listFavoriteDisconnectedItems[indexPath.row] : self._listDisconnectedItems[indexPath.row]
        }
        
        
        self.delegate = self.presenter?.showDetailPeripheralDevice(from: self, item: model)
        self._centralManager.stopScan()
        self._centralManager.connect(model.peripheralDevice)
        self.tableView.reloadData()
    }
}

extension ShowAllViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self._isFilterFavorite ? self._listFavoriteConnectedItems.count : self._listConnectedItems.count
        } else {
            return self._isFilterFavorite ? self._listFavoriteDisconnectedItems.count : self._listDisconnectedItems.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Bounded Device"
        } else {
            return "Nearby Device"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: self._reuseIdentifier, for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }
        
        var listItems: [PeripheralDevice]
        var listFavoriteItems: [PeripheralDevice]
        
        if indexPath.section == 0 {
            listItems = self._listConnectedItems
            listFavoriteItems = self._listFavoriteConnectedItems
        } else {
            listItems = self._listDisconnectedItems
            listFavoriteItems = self._listFavoriteDisconnectedItems
        }
        
        if !self._isFilterFavorite {
            let model = listItems[indexPath.row]
            cell.configCell(for: model)
        } else {
            let model = listFavoriteItems[indexPath.row]
            cell.configCell(for: model)
        }

        return cell
    }
}

extension ShowAllViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central state is unknown")
        case .resetting:
            print("central state is resetting")
        case .unsupported:
            print("central state is unsupported")
        case .unauthorized:
            print("central state is unauthorized")
        case .poweredOff:
            print("central state is powered off")
        case .poweredOn:
            print("central state is powered on")
            central.scanForPeripherals(withServices: [kDEVICE_INFORMATION_SERVICE_CBUUID,
                                                      kHEART_RATE_SERVICE_CBUUID,
                                                      kSHINE_MISFIT_SERVICE_BUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //Find serial string of peripheral
        var serialString: String = "Unknown"
        if let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
            assert(manufacturerData.count >= 11)
            let serial = manufacturerData.subdata(in: 2..<12)
            let data = Data(bytes: serial)
            serialString = String(data: data, encoding: .utf8) ?? "Unknown"
        }
        let newPeripheralDevice = PeripheralDevice(peripheral: peripheral, rssi: RSSI, serial: serialString)
        
        //update item's rssi
        let index = self._listDisconnectedItems.lastIndex(where: { $0.peripheralDevice.identifier == newPeripheralDevice.peripheralDevice.identifier })
        
        if let alreadyIndex = index {
            self._listDisconnectedItems[alreadyIndex].rssi = RSSI
        } else {
            self._listDisconnectedItems.append(newPeripheralDevice)
        }
        
        //Sort list of items
        if self._isSorted {
            _listDisconnectedItems = _listDisconnectedItems.sorted(by: { $0.rssi.compare($1.rssi) == .orderedAscending })
        } else {
            _listDisconnectedItems = _listDisconnectedItems.sorted(by: { $0.rssi.compare($1.rssi) == .orderedDescending })
        }
        self.tableView.reloadData()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([kSHINE_MISFIT_SERVICE_BUUID, kDEVICE_INFORMATION_SERVICE_CBUUID])
        self.delegate?.showAllView(didChangeStatus: peripheral.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.delegate?.showAllView(didChangeStatus: peripheral.state)
    }
    
   
}

extension ShowAllViewController: ShowDetailViewDelegate {
    func showDetailView(willChangeState state: CBPeripheralState, for peripheral: CBPeripheral) {
        switch state {
        case .connected:
            self._centralManager.connect(peripheral)
        case .disconnected:
            self._centralManager.cancelPeripheralConnection(peripheral)
        default:
            break
        }
    }
}
