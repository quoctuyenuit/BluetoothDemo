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
 
 - kCHARACTERISTIC_MISFIT_BUUID: BUUID để lọc characteristic xoay kim
 
 - kDEVICE_INFORMATION_MANUFACTURER_NAME_STRING: BUUID để lấy thông Manufacturer name
 
 - kDEVICE_INFORMATION_SERIAL_VERSION_STRING: BUUID để lấy serial number
 
 - kDEVICE_INFORMATION_FW_REVISION_STRING: BUUID để lấy Firmware Revision string
 
 - _turnNeedleCharacteristic: Characteristic xoay kim đồng hồ dùng để lưu lại khi cần write command xoay kim
 */

protocol ShowDetailViewDelegate {
    //To change state of the peripheral device by Central Manager
    func showDetailView(willChangeState state: CBPeripheralState, for peripheral: CBPeripheral)
}

class ShowDetailViewController: UIViewController, ShowDetailViewProtocol {
    
    //MARK: - Common properties
    var presenter: ShowDetailPresenterProtocol?
    public var delegate: ShowDetailViewDelegate?
    private var _model: PeripheralDevice!
    private static let LINE_GAP: CGFloat = 10
    private static let PADDING: CGFloat = 30
    private let kCHARACTERISTIC_MISFIT_BUUID = CBUUID(nsuuid: UUID(uuidString: "3dda0002-957f-7d4a-34a6-74696673696d")!)
    private let kDEVICE_INFORMATION_MANUFACTURER_NAME_STRING = CBUUID(string: "2A29")
    private let kDEVICE_INFORMATION_SERIAL_VERSION_STRING = CBUUID(string: "2A25")
    private let kDEVICE_INFORMATION_FW_REVISION_STRING = CBUUID(string: "2A26")
    
    private var _turnNeedleCharacteristic: CBCharacteristic?
    
    private lazy var _nameLabel: UILabel = {
        return setupLabelTitle(for: "Name:")
    }()
    
    private lazy var _statusLabel: UILabel = {
        return setupLabelTitle(for: "Status:")
    }()
    
    private lazy var _serialLabel: UILabel = {
        return setupLabelTitle(for: "Serial:")
    }()
    
    private lazy var _macAddressLabel: UILabel = {
        return setupLabelTitle(for: "Mac Address:")
    }()
    
    private lazy var _deviceFamilyLabel: UILabel = {
        return setupLabelTitle(for: "Device Family:")
    }()
    
    private lazy var _fwVersionLabel: UILabel = {
        return setupLabelTitle(for: "FW version:")
    }()
    
    private lazy var _uAppVersionLabel: UILabel = {
        return setupLabelTitle(for: "uApp version:")
    }()
    
    
    private lazy var _name: UILabel = {
        return setupLabelTitle(for: self._model.peripheralDevice.name ?? "Unknown")
    }()
    
    private lazy var _status: UILabel = {
        switch self._model.peripheralDevice.state {
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
    
    private lazy var _serial: UILabel = {
        return setupLabelTitle(for: "Unknown")
    }()
    
    private lazy var _macAddress: UILabel = {
        return setupLabelTitle(for: "Unknown")
    }()
    
    private lazy var _deviceFamily: UILabel = {
        return setupLabelTitle(for: "Unknown")
    }()
    
    private lazy var _fwVersion: UILabel = {
        return setupLabelTitle(for: "Unknown")
    }()
    
    private lazy var _uAppVersion: UILabel = {
        return setupLabelTitle(for: "Unknown")
    }()
    
    private lazy var _turnTheNeedleButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Turn the needle", for: .normal)
        btn.setTitleColor(UIColor.blue, for: .normal)
        btn.setTitleColor(UIColor.lightGray, for: .application)
        btn.addTarget(self, action: #selector(turnTheNeedle(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var _changeConnectStateButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Cancel Connect", for: .normal)
        btn.setTitleColor(UIColor.blue, for: .normal)
        btn.setTitleColor(UIColor.lightGray, for: .application)
        btn.addTarget(self, action: #selector(changeConnectTapped(_:)), for: .touchUpInside)
        return btn
    }()
    
    
    private lazy var _titleBound = UIView()
    private lazy var _contentBound = UIView()
    
    
    @objc private func turnTheNeedle(_ sender: UIButton) {
        guard let characteristic = self._turnNeedleCharacteristic else { return }
        self.presenter?.writeCommandSample(to: self._model.peripheralDevice, for: characteristic)
    }
    
    @objc private func changeConnectTapped(_ sender: UIButton) {
        switch self._model.peripheralDevice.state {
        case .disconnected:
            self.delegate?.showDetailView(willChangeState: .connected, for: self._model.peripheralDevice)
            self._status.text = "Connecting"
        case .connecting:
            self.delegate?.showDetailView(willChangeState: .disconnected, for: self._model.peripheralDevice)
            self._status.text = "Disconnecting"
        case .connected:
            self.delegate?.showDetailView(willChangeState: .disconnected, for: self._model.peripheralDevice)
            self._status.text = "Disconnecting"
        case .disconnecting:
            self.delegate?.showDetailView(willChangeState: .connected, for: self._model.peripheralDevice)
            self._status.text = "Connecting"
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
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self._titleBound)
        self.view.addSubview(self._contentBound)
        self.view.addSubview(self._turnTheNeedleButton)
        self.view.addSubview(self._changeConnectStateButton)
        
        self.setupTitle()
        self.setupContent()
        
        self._titleBound.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(ShowDetailViewController.PADDING)
            make.left.equalToSuperview().offset(ShowDetailViewController.PADDING)
            make.width.height.greaterThanOrEqualTo(0)
        }
        
        self._contentBound.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(ShowDetailViewController.PADDING)
            make.left.equalTo(self._titleBound.snp.right).offset(ShowDetailViewController.PADDING)
            make.right.equalToSuperview()
            make.width.greaterThanOrEqualTo(0)
        }
        
        self._turnTheNeedleButton.snp.makeConstraints { (make) in
            make.top.equalTo(self._contentBound.snp.bottom).offset(20)
            make.width.height.greaterThanOrEqualTo(0)
            make.centerX.equalToSuperview()
        }
        
        self._changeConnectStateButton.snp.makeConstraints { (make) in
            make.top.equalTo(self._turnTheNeedleButton.snp.bottom).offset(20)
            make.width.height.greaterThanOrEqualTo(0)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupTitle() {
        self._titleBound.addSubview(self._nameLabel)
        self._titleBound.addSubview(self._statusLabel)
        self._titleBound.addSubview(self._serialLabel)
        self._titleBound.addSubview(self._macAddressLabel)
        self._titleBound.addSubview(self._deviceFamilyLabel)
        self._titleBound.addSubview(self._fwVersionLabel)
        self._titleBound.addSubview(self._uAppVersionLabel)
        
        self._nameLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
        }
        
        self._statusLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self._nameLabel.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
        }

        self._serialLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self._statusLabel.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
        }
        self._macAddressLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self._serialLabel.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
            make.right.equalToSuperview().priority(ConstraintPriority.medium)
        }
        self._deviceFamilyLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self._macAddressLabel.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
        }
        self._fwVersionLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self._deviceFamilyLabel.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
        }
        self._uAppVersionLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self._fwVersionLabel.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
            make.bottom.equalToSuperview().priority(ConstraintPriority.medium)
        }
    }
    
    private func setupContent() {
        self._contentBound.addSubview(self._name)
        self._contentBound.addSubview(self._status)
        self._contentBound.addSubview(self._serial)
        self._contentBound.addSubview(self._macAddress)
        self._contentBound.addSubview(self._deviceFamily)
        self._contentBound.addSubview(self._fwVersion)
        self._contentBound.addSubview(self._uAppVersion)
        
        self._name.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
        }
        self._status.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self._name.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
        }
        self._serial.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self._status.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
        }
        self._macAddress.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self._serial.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
        }
        self._deviceFamily.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self._macAddress.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
        }
        self._fwVersion.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self._deviceFamily.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
        }
        self._uAppVersion.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
            make.top.equalTo(self._fwVersion.snp.bottom).offset(ShowDetailViewController.LINE_GAP)
            make.bottom.equalToSuperview().priority(ConstraintPriority.medium)
        }
    }
    
    //MARK: - Initialization
    convenience init(for model: PeripheralDevice) {
        self.init(nibName: nil, bundle: nil)
        self._model = model
        self._model.peripheralDevice.delegate = self
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
                self._turnNeedleCharacteristic = $0
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(characteristic)
        switch characteristic.uuid {
        case kDEVICE_INFORMATION_MANUFACTURER_NAME_STRING:
            guard let data = characteristic.value else { return }
            let manufacturerNameString = String(data: data, encoding: .utf8)
            self._macAddress.text = manufacturerNameString
        case kDEVICE_INFORMATION_SERIAL_VERSION_STRING:
            guard let data = characteristic.value else { return }
            let manufacturerNameString = String(data: data, encoding: .utf8)
            self._serial.text = manufacturerNameString
        case kDEVICE_INFORMATION_FW_REVISION_STRING:
            guard let data = characteristic.value else { return }
            let manufacturerNameString = String(data: data, encoding: .utf8)
            self._fwVersion.text = manufacturerNameString
        default:
            break
        }
    }
}

extension ShowDetailViewController: ShowAllViewDelegate {
    func showAllView(didChangeStatus status: CBPeripheralState) {
        switch status {
        case .disconnected:
            self._status.text = "Disconnected"
            self._changeConnectStateButton.setTitle("Connect", for: .normal)
        case .connecting:
            self._status.text = "Connecting"
            self._changeConnectStateButton.setTitle("Cancel Connect", for: .normal)
        case .connected:
            self._status.text = "Connected"
            self._changeConnectStateButton.setTitle("Disconnect", for: .normal)
        case .disconnecting:
            self._status.text = "Disconnecting"
            self._changeConnectStateButton.setTitle("Cancel Disconnect", for: .normal)
        }
    }
}
