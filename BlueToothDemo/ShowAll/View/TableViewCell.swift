//
//  TableViewCell.swift
//  BlueToothDemo
//
//  Created by Mr Tuyen Nguyen Quoc Tuyen on 12/3/18.
//  Copyright © 2018 Mr Tuyen Nguyen Quoc Tuyen. All rights reserved.
//

import UIKit
import SnapKit

protocol TableViewCellDelegate {
    func tableViewCell(didChangeFavorite value: Bool, for name: String)
}

class TableViewCell: UITableViewCell {

    var delegate: TableViewCellDelegate?
    
    private var _peripheralDevice: PeripheralDevice?
    
    private var _isChecked = false {
        didSet {
            let img = self._isChecked ? UIImage(named: "ico_rating_checked"): UIImage(named: "ico_rating_unchecked")
            self._favoriteIcon.setImage(img, for: .normal)
        }
    }
    private lazy var _favoriteIcon: UIButton = {
        let icon = UIButton()
        icon.setImage(UIImage(named: "ico_rating_unchecked"), for: .normal)
        icon.addTarget(self, action: #selector(checkTapped(_:)), for: .touchUpInside)
        return icon
    }()
    
    private lazy var _nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var _serialLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var _statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var _macAddressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var _rssiLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var _contentBoundView = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
        self.selectionStyle = .default
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(self._favoriteIcon)
        self.addSubview(self._contentBoundView)
        self._contentBoundView.addSubview(self._nameLabel)
        self._contentBoundView.addSubview(self._statusLabel)
        self._contentBoundView.addSubview(self._rssiLabel)
        self._contentBoundView.addSubview(self._macAddressLabel)
        
        self._favoriteIcon.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.width.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
        self._nameLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
        }
        
        self._statusLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(self._nameLabel.snp.bottom).offset(6)
            make.width.height.greaterThanOrEqualTo(0)
        }
        
        self._rssiLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self._statusLabel.snp.top)
            make.right.equalToSuperview().offset(-10)
            make.width.height.greaterThanOrEqualTo(0)
        }
        
        self._macAddressLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self._statusLabel.snp.bottom).offset(6)
            make.bottom.equalToSuperview().priority(.medium)
            make.height.greaterThanOrEqualTo(0)
        }
        
        self._contentBoundView.snp.makeConstraints { (make) in
            make.left.equalTo(self._favoriteIcon.snp.right).offset(20)
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    public func configCell(for model: PeripheralDevice) {
        
        if let name = model.peripheralDevice.name, !name.isEmpty {
            self._nameLabel.text = "\(name) - \(model.serialString)"
        } else {
            self._nameLabel.text = "Unknown - \(model.serialString)"
        }
        
        switch model.peripheralDevice.state {
        case .disconnected:
            self._statusLabel.text = "Disconnected"
        case .connecting:
            self._statusLabel.text = "Connecting"
        case .connected:
            self._statusLabel.text = "Connected"
        case .disconnecting:
            self._statusLabel.text = "Disconnecting"
        }
        
        self._rssiLabel.text = "\(model.rssi)"
        self._macAddressLabel.text = model.peripheralDevice.identifier.uuidString
        self._isChecked = model.isFavorite
        self._peripheralDevice = model
    }
    
    @objc private func checkTapped(_ sender: UIButton) {
        self._isChecked = !self._isChecked
        self._peripheralDevice?.isFavorite = self._isChecked
    }

}
