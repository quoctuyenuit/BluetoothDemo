//
//  ShowDetailViewController.swift
//  BlueToothDemo
//
//  Created by Mr Tuyen Nguyen Quoc Tuyen on 12/4/18.
//  Copyright © 2018 Mr Tuyen Nguyen Quoc Tuyen. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import CoreBluetooth

/*
 - lineGap: Khoảng cách giữa các hàng
 
 - padding: Khoảng cách từ connect so với viền xung quanh
 
 - model: biến chứa thông tin item cần show detail
 
 - CHARACTERISTIC_MISFIT_BUUID: BUUID để lọc characteristic xoay kim
 */

protocol ShowDetailViewDelegate {
    func showDetailView(willChangeState state: CBPeripheralState, for peripheral: CBPeripheral)
}

class ShowDetailViewController: UIViewController, ShowDetailViewProtocol {
    
    //MARK: - Common properties
    var presenter: ShowDetailPresenterProtocol?
    public var delegate: ShowDetailViewDelegate?
    var model: PeripheralDevice!
    private static let LINE_GAP: CGFloat = 10
    private static let PADDING: CGFloat = 30
    private let kCHARACTERISTIC_MISFIT_BUUID = CBUUID(nsuuid: UUID(uuidString: "3dda0002-957f-7d4a-34a6-74696673696d")!)
    private let kDEVICE_INFORMATION_MANUFACTURER_NAME_STRING = CBUUID(string: "2A29")
    private let kDEVICE_INFORMATION_SERIAL_VERSION_STRING = CBUUID(string: "2A25")
    private let kDEVICE_INFORMATION_MODEL_NUMBER_STRING = CBUUID(string: "2A24")
    private let kDEVICE_INFORMATION_FW_REVISION_STRING = CBUUID(string: "2A26")
    private let kDEVICE_INFORMATION_SYSTEM_ID = CBUUID(string: "2A23")
    
    private var turnNeedleCharacteristic: CBCharacteristic?
    
    private lazy var nameLabel: UILabel = {
        return setupLabelTitle(for: "Name:")
    }()
    private lazy var statusLabel: UILabel = {
        return setupLabelTitle(for: "Status:")
    }()
    private lazy var serialLabel: UILabel = {
        return setupLabelTitle(for: "Serial:")
    }()
    private lazy var macAddressLabel: UILabel = {
        return setupLabelTitle(for: "Mac Address:")
    }()
    private lazy var deviceFamilyLabel: UILabel = {
        return setupLabelTitle(for: "Device Family:")
    }()
    private lazy var fwVersionLabel: UILabel = {
        return setupLabelTitle(for: "FW version:")
    }()
    private lazy var uAppVersionLabel: UILabel = {
        return setupLabelTitle(for: "uApp version:")
    }()
    
    
    private lazy var name: UILabel = {
        return setupLabelTitle(for: self.model.peripheralDevice.name ?? "Unknown")
    }()
    private lazy var status: UILabel = {
        switch self.model.peripheralDevice.state {
        case .disconnected:
            return setupLabelTitle(for: "Disconnected")
        case .connecting:
            return setupLabelTitle(for: "Connecting")
        case .connected:
            return setupLabelTitle(for: "Connected")
        case .disconnecting:
            return setupLabelTitle(for: "Disconnecting")
        }
        
    }()
    private lazy var serial: UILabel = {
        return setupLabelTitle(for: "Unknown")
    }()
    private lazy var macAddress: UILabel = {
        return setupLabelTitle(for: "Unknown")
    }()
    private lazy var deviceFamily: UILabel = {
        return setupLabelTitle(for: "Unknown")
    }()
    private lazy var fwVersion: UILabel = {
        return setupLabelTitle(for: "Unknown")
    }()
    private lazy var uAppVersion: UILabel = {
        return setupLabelTitle(for: "Unknown")
    }()
    
    private lazy var turnTheNeedleButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Turn the needle", for: .normal)
        btn.setTitleColor(UIColor.blue, for: .normal)
        btn.setTitleColor(UIColor.lightGray, for: .application)
        btn.addTarget(self, action: #selector(turnTheNeedle(_:)), for: .touchUpInside)
        return btn
    }()
    private lazy var changeConnectStateButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Cancel Connect", for: .normal)
        btn.setTitleColor(UIColor.blue, for: .normal)
        btn.setTitleColor(UIColor.lightGray, for: .application)
        btn.addTarget(self, action: #selector(changeConnectTapped(_:)), for: .touchUpInside)
        return btn
    }()
    
    
    private lazy var titleBound = UIView()
    private lazy var contentBound = UIView()
    
    
    @objc private func turnTheNeedle(_ sender: UIButton) {
        guard let characteristic = self.turnNeedleCharacteristic else { return }
        self.presenter?.writeCommandSample(to: self.model.peripheralDevice, for: characteristic)
    }
    
    @objc private func changeConnectTapped(_ sender: UIButton) {
        switch self.model.peripheralDevice.state {
        case .disconnected:
            self.delegate?.showDetailView(willChangeState: .connected, for: self.model.peripheralDevice)
        case .connecting:
            self.delegate?.showDetailView(willChangeState: .disconnected, for: self.model.peripheralDevice)
        case .connected:
            self.delegate?.showDetailView(willChangeState: .disconnected, for: self.model.peripheralDevice)
        case .disconnecting:
            self.delegate?.showDetailView(willChangeState: .connected, for: self.model.peripheralDevice)
        }
    }
    
    //MARK: - Setup view function
    private func setupLabelTitle(for titleName: String) -> UILabel {
        let label = UILabel()
        label.text = titleName
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.backgroundColor = UIColor.white
        label.textAlignment = NSTextAlignment.left
        return label
    }
    
    private func setupView() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.titleBound)
        self.view.addSubview(self.contentBound)
        self.view.addSubview(self.turnTheNeedleButton)
        self.view.addSubview(self.changeConnectStateButton)
        
        self.setupTitle()
        self.setupContent()
        
        self.titleBound.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(ShowDetailViewController.PADDING)
            make.left.equalToSuperview().offset(ShowDetailViewController.PADDING)
            make.width.height.greaterThanOrEqualTo(0)
        }
        
        self.contentBound.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(ShowDetailViewController.PADDING)
            make.left.equalTo(self.titleBound.snp.right).offset(ShowDetailViewController.PADDING)
            make.right.equalToSuperview()
            make.width.greaterThanOrEqualTo(0)
        }
        
        self.turnTheNeedleButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentBound.snp.bottom).offset(20)
            make.width.height.greaterThanOrEqualTo(0)
            make.centerX.equalToSuperview()
        }
        
        self.changeConnectStateButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.turnTheNeedleButton.snp.bottom).offset(20)
            make.width.height.greaterThanOrEqualTo(0)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupTitle() {
        self.titleBound.addSubview(self.nameLabel)
        self.titleBound.addSubview(self.statusLabel)
        self.titleBound.addSubview(self.serialLabel)
        self.titleBound.addSubview(self.macAddressLabel)
        self.titleBound.addSubview(self.deviceFamilyLabel)
        self.titleBound.addSubview(self.fwVersionLabel)
        self.titleBound.addSubview(self.uAppVersionLabel)
        
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
        }
        
        self.statusLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
        }

        self.serialLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self.statusLabel.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
        }
        self.macAddressLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self.serialLabel.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
            make.right.equalToSuperview().priority(ConstraintPriority.medium)
        }
        self.deviceFamilyLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self.macAddressLabel.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
        }
        self.fwVersionLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self.deviceFamilyLabel.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
        }
        self.uAppVersionLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self.fwVersionLabel.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
            make.bottom.equalToSuperview().priority(ConstraintPriority.medium)
        }
    }
    
    private func setupContent() {
        self.contentBound.addSubview(self.name)
        self.contentBound.addSubview(self.status)
        self.contentBound.addSubview(self.serial)
        self.contentBound.addSubview(self.macAddress)
        self.contentBound.addSubview(self.deviceFamily)
        self.contentBound.addSubview(self.fwVersion)
        self.contentBound.addSubview(self.uAppVersion)
        
        self.name.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
        }
        self.status.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self.name.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
        }
        self.serial.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self.status.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
        }
        self.macAddress.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self.serial.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
        }
        self.deviceFamily.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self.macAddress.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
        }
        self.fwVersion.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self.deviceFamily.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
        }
        self.uAppVersion.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self.fwVersion.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
            make.bottom.equalToSuperview().priority(ConstraintPriority.medium)
        }
    }
    
    //MARK: - Initialization
    convenience init(for model: PeripheralDevice) {
        self.init(nibName: nil, bundle: nil)
        self.model = model
        self.model.peripheralDevice.delegate = self
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Override function
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
}

extension ShowDetailViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        services.forEach {
            peripheral.discoverCharacteristics(nil, for: $0)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        characteristics.forEach {
            if $0.properties.contains(.read) {
                peripheral.readValue(for: $0)
            }
            
            if $0.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: $0)
            }
            
            if $0.properties.contains(.write) {
                self.turnNeedleCharacteristic = $0
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(characteristic)
        switch characteristic.uuid {
        case kDEVICE_INFORMATION_MANUFACTURER_NAME_STRING:
            guard let data = characteristic.value else { return }
            let manufacturerNameString = String(data: data, encoding: .utf8)
            self.macAddress.text = manufacturerNameString
        case kDEVICE_INFORMATION_SERIAL_VERSION_STRING:
            guard let data = characteristic.value else { return }
            let manufacturerNameString = String(data: data, encoding: .utf8)
            self.serial.text = manufacturerNameString
        case kDEVICE_INFORMATION_FW_REVISION_STRING:
            guard let data = characteristic.value else { return }
            let manufacturerNameString = String(data: data, encoding: .utf8)
            self.fwVersion.text = manufacturerNameString
        case kDEVICE_INFORMATION_SYSTEM_ID:
            guard let data = characteristic.value else { return }
//            self.uAppVersion.text = manufacturerNameString
        default:
            break
        }
    }
}

extension ShowDetailViewController: ShowAllViewDelegate {
    func showAllView(didChangeStatus status: CBPeripheralState) {
        switch status {
        case .disconnected:
            self.status.text = "Disconnected"
            self.changeConnectStateButton.setTitle("Connect", for: .normal)
        case .connecting:
            self.status.text = "Connecting"
            self.changeConnectStateButton.setTitle("Cancel Connect", for: .normal)
        case .connected:
            self.status.text = "Connected"
            self.changeConnectStateButton.setTitle("Disconnect", for: .normal)
        case .disconnecting:
            self.status.text = "Disconnecting"
            self.changeConnectStateButton.setTitle("Cancel Disconnect", for: .normal)
        }
    }
}
