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
    
    private var peripheralDevice: PeripheralDevice?
    
    private var isChecked = false {
        didSet {
            let img = self.isChecked ? UIImage(named: "ico_rating_checked"): UIImage(named: "ico_rating_unchecked")
            self.favoriteIcon.setImage(img, for: .normal)
        }
    }
    private lazy var favoriteIcon: UIButton = {
        let icon = UIButton()
        icon.setImage(UIImage(named: "ico_rating_unchecked"), for: .normal)
        icon.addTarget(self, action: #selector(checkTapped(_:)), for: .touchUpInside)
        return icon
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var serialLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var macAddressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var rssiLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var contentBoundView = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        self.addSubview(self.favoriteIcon)
        self.addSubview(self.contentBoundView)
        self.contentBoundView.addSubview(self.nameLabel)
        self.contentBoundView.addSubview(self.statusLabel)
        self.contentBoundView.addSubview(self.rssiLabel)
        self.contentBoundView.addSubview(self.macAddressLabel)
        
        self.favoriteIcon.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.width.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(0)
        }
        
        self.statusLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(self.nameLabel.snp.bottom).offset(6)
            make.width.height.greaterThanOrEqualTo(0)
        }
        
        self.rssiLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.statusLabel.snp.top)
            make.right.equalToSuperview().offset(-10)
            make.width.height.greaterThanOrEqualTo(0)
        }
        
        self.macAddressLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.statusLabel.snp.bottom).offset(6)
            make.bottom.equalToSuperview().priority(.medium)
            make.height.greaterThanOrEqualTo(0)
        }
        
        self.contentBoundView.snp.makeConstraints { (make) in
            make.left.equalTo(self.favoriteIcon.snp.right).offset(20)
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    public func updateData(for model: PeripheralDevice) {
        
        if let name = model.peripheralDevice.name, !name.isEmpty {
            self.nameLabel.text = name
        } else {
            self.nameLabel.text = "unknown"
        }
        
        switch model.peripheralDevice.state {
        case .disconnected:
            self.statusLabel.text = "Disconnected"
        case .connecting:
            self.statusLabel.text = "Connecting"
        case .connected:
            self.statusLabel.text = "Connected"
        case .disconnecting:
            self.statusLabel.text = "Disconnecting"
        }
        
        self.rssiLabel.text = "\(model.rssi)"
        self.macAddressLabel.text = model.peripheralDevice.identifier.uuidString
        self.isChecked = model.isFavorite
        self.peripheralDevice = model
    }
    
    @objc private func checkTapped(_ sender: UIButton) {
        self.isChecked = !self.isChecked
        self.peripheralDevice?.isFavorite = self.isChecked
    }

}
