//
//  NewFacilityViewController.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/08/26.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import UIKit
import CoreLocation

final class NewFacilityViewController: UITableViewController {
    
    enum Item: String, CaseIterable {
        case
        latitude        = "緯度",
        longitude       = "経度",
        date            = "日時",
        number          = "管理番号",
        facilityType    = "種別",
        stanchionType   = "支柱形式"
    }
    
    var location: CLLocation?
    
    private var textField: UITextField?
    private let date = Date()
    private var facilityType: String?
    private var stanchionType: String?
    private var facilityTypes = ["道路標識", "道路情報提供装置", "道路情報提供装置（添架物有）", "道路照明施設", "その他"]
    private var stanchionTypes = ["路側式", "片持式（逆Ｌ型）", "片持式（Ｆ型）", "片持式（テーパーポール型）","片持式（Ｔ型）",
                                  "門形式（オーバーヘッド型）", "添架式","ポール照明方式（テーパーポール型）",
                                  "ポール照明方式（直線型）", "ポール照明方式（Ｙ型）", "トンネル照明", "その他"]

    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Item.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = Item.allCases[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: item == .number ? "input" : "cell", for: indexPath)
        cell.textLabel?.text = item.rawValue
        
        switch item {
        case .facilityType, .stanchionType:
            cell.selectionStyle = .default
            cell.accessoryType = .disclosureIndicator
        default:
            cell.selectionStyle = .none
            cell.accessoryType = .none
        }
        
        switch item {
        case .latitude:         cell.detailTextLabel?.text = location.flatMap({ "\($0.coordinate.latitude)" })
        case .longitude:        cell.detailTextLabel?.text = location.flatMap({ "\($0.coordinate.longitude)" })
        case .date:             cell.detailTextLabel?.text = date.string(.dateTime(.hyphen))
        case .facilityType:     cell.detailTextLabel?.text = facilityType ?? "選択してください"
        case .stanchionType:    cell.detailTextLabel?.text = stanchionType ?? "選択してください"
        case .number:
            if textField == nil {
                textField = cell.contentView.subviews.first(where: { $0 is UITextField }) as? UITextField
                textField?.text = date.string(.timestamp)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let options: [String]
        let item = Item.allCases[indexPath.row]
        switch item {
        case .facilityType : options = facilityTypes
        case .stanchionType : options = stanchionTypes
        case .number:
            textField?.becomeFirstResponder()
            return
        default:
            view.endEditing(false)
            return
        }
        view.endEditing(false)
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        options.forEach { option in
            actionSheet.addAction(.init(title: option, style: .default, handler: { [weak self] _ in
                guard let self = self else {
                    return
                }
                switch item {
                case .facilityType : self.facilityType = option
                case .stanchionType : self.stanchionType = option
                default: return
                }
                self.tableView.reloadData()
                self.updateSaveBottom()
            }))
        }
        
        let cell = tableView.cellForRow(at: indexPath)
        actionSheet.popoverPresentationController?.sourceView = cell?.detailTextLabel
        actionSheet.popoverPresentationController?.sourceRect = cell?.detailTextLabel?.bounds ?? .zero
        present(actionSheet, animated: true)
    }
    
    @IBAction private func close(_ sender: Any) {
        view.endEditing(false)
        dismiss(animated: true)
    }
       
    @IBAction private func save(_ sender: Any) {
        view.endEditing(false)
        guard let facilityType = facilityType,
            let stanchionType = stanchionType,
            let number = textField?.text,
            let location = location
        else {
            return
        }
        
        if Index.shared?.facilities?.contains(where: {
            $0.facility?.serialNumber == number
        }) == true {
            showAlert(title: "エラー", message: "管理番号は既に存在しています。")
            textField?.becomeFirstResponder()
            return
        }
        
        if DataManager.creatNewFacility(facilityType: facilityType,
                                        stanchionType: stanchionType,
                                        serialNumber: number,
                                        location: location) {
            
            weak var presenting = presentingViewController
            dismiss(animated: true) {
                if let presenting = presenting {
                    WebViewController.openFacility(serialNumber: number, from: presenting)
                }
            }
        } else {
            dismiss(animated: true)
        }

        
    }
    
    @IBAction func inputDidChange(_ sender: UITextField) {
        var text = sender.text
        // 入力不可の文字を排除
        ["*", "＊", "/", "／", " ", "　", "\\", "＼", "￥", "¥", "@", "＠"].forEach { character in
            text = text?.replacingOccurrences(of: character, with: "")
        }
        sender.text = text
        updateSaveBottom()
    }
    
    private func updateSaveBottom() {
        navigationItem.rightBarButtonItem?.isEnabled =
            facilityType?.isEmpty == false &&
            stanchionType?.isEmpty == false &&
            textField?.text?.isEmpty == false
    }
}
