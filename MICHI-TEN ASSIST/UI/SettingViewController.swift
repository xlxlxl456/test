//
//  SettingViewController.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/06/24.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import UIKit

extension SettingViewController {
    typealias MarkerColor = Setting.ARInfo.MarkerColor
    typealias InputLimit = Setting.ARInfo.InputLimit
    
    
    enum Item: CaseIterable {
        case time, timeCorrection, sma, markerSize, guide, gpsLog, markerColorBefore, markerColorAfter, alphaLevel, markerType, showFilter, maskL, maskR
        
        var name: String {
            switch self {
            case .time:                 return "現在時刻　"
            case .timeCorrection:       return ""//"補正秒数" StoryBoardにて設定
            case .sma:                  return "SMA平均化数"
            case .markerSize:           return "サイズ"
            case .guide:                return "ガイドを表示する"
            case .gpsLog:               return "GPSのログを残す"
            case .markerColorBefore:    return "点検中のマーカー色"
            case .markerColorAfter:     return "点検完了のマーカー色"
            case .alphaLevel:           return "透明度"
            case .markerType:           return "マーカー形状"
            case .showFilter:           return "マーカー表示可能距離"
            case .maskL:                return "表示範囲角度（左前方）"
            case .maskR:                return "表示範囲角度（右前方）"
            }
        }
        
        var reusableId: String {
            switch self {
            case .time:
                return "time"
            case .timeCorrection:
                return "timeCorrection"
            case .sma, .markerSize, .alphaLevel, .showFilter, .maskL, .maskR:
                return "number"
            case .guide, .gpsLog:
                return "switch"
            case .markerColorBefore, .markerColorAfter:
                return "color"
            case .markerType:
                return "shape"
            }
        }
        
        var numberFormat: (range: ClosedRange<Double>, step: Double, unit: String?)? {
            switch self {
            case .timeCorrection:   return (InputLimit.timeCorrection.range, 1, "秒")
            case .sma:              return (InputLimit.sma.range, 1, "回")
            case .markerSize:       return (InputLimit.markerSize.range, 0.1, nil)
            case .alphaLevel:       return (InputLimit.alphaLevel.range, 1, nil)
            case .showFilter:       return (InputLimit.showFilter.range, 1, "m")
            case .maskL:            return (InputLimit.maskL.range, 1, "°")
            case .maskR:            return (InputLimit.maskR.range, 1, "°")
            default:                return nil
            }
        }
    }
}

final class SettingViewController: UITableViewController {
    
    @IBOutlet private weak var versionLbl: UILabel! {
        didSet {
            let version = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
            versionLbl.text = version.flatMap { "Version: \($0)" }
        }
    }
    
    private var arInfo = Setting.shared?.arInfo ?? Setting.ARInfo()
    
    private let list: [[Item]] = [
        [.time, .timeCorrection],
        [.sma, .gpsLog],
        [.guide, .markerColorBefore, .markerColorAfter, .markerType, .markerSize, .alphaLevel, .showFilter, .maskL, .maskR]
    ]
    
    private var timer: Timer?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        
        let timer = Timer(fire: Date(), interval: 1, repeats: true) {[weak self] _ in
            guard let self = self,
                let cell = self.tableView.visibleCells.first(where: {
                $0.textLabel?.text?.hasPrefix(Item.time.name) == true
            }) as? SettingTimeCell else {
                return
            }
            cell.updateTime(timeCorrection: self.arInfo.timeCorrection)
        }
        self.timer = timer
        RunLoop.main.add(timer, forMode: .default)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = list[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.reusableId, for: indexPath)
        
        cell.textLabel?.text = item.name
        
        if let numberCell = cell as? SettingNumberCell {
            numberCell.steup(item: item, arInfo: arInfo) { [weak self] (item, value) in
                switch item {
                case .timeCorrection:   self?.arInfo.timeCorrection = Int(value)
                case .sma:              self?.arInfo.sma = Int(value)
                case .markerSize:       self?.arInfo.markerSize = Double(value)
                case .alphaLevel:       self?.arInfo.alphaLevel = Int(value)
                case .showFilter:       self?.arInfo.showFilter = Int(value)
                case .maskL:            self?.arInfo.maskL = Int(value)
                case .maskR:            self?.arInfo.maskR = Int(value)
                default:                break
                }
            }
        }
        
        if let colorCell = cell as? SettingColorCell,
            let value = { () -> MarkerColor? in
                switch item {
                case .markerColorBefore:  return arInfo.markerColorBefore
                case .markerColorAfter:   return arInfo.markerColorAfter
                default: return nil
                }
            }()
        {
            colorCell.steup(value: value) { [weak self] value in
                switch item {
                case .markerColorBefore:   self?.arInfo.markerColorBefore = value
                case .markerColorAfter:    self?.arInfo.markerColorAfter = value
                default: break
                }
            }
        }
        
        if let swit = cell.accessoryView as? UISwitch {
            switch item {
            case .guide:    swit.isOn = Bool(truncating: arInfo.guide as NSNumber)
            case .gpsLog:   swit.isOn = Bool(truncating: arInfo.gpsLog as NSNumber)
            default: break
            }
        }
        
        if let seg = cell.accessoryView as? UISegmentedControl {
            switch item {
            case .markerType: seg.selectedSegmentIndex = arInfo.markerType.rawValue
            default: break
            }
        }
        
        return cell
    }
    
    @IBAction private func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction private func save(_ sender: Any) {
        Setting.shared?.arInfo = self.arInfo
        Setting.shared?.save()
        ARManager.shared.updateAR()
        dismiss(animated: true)
    }
    
    @IBAction private func showTimeCorrectionTip(_ sender: Any) {
        showAlert(title: "補正秒数", message:
            "タブレット\t10:00:00\nデジカメ\t\t09:59:57\n" +
            "→　補正値は「-3」秒と入力\n\n" +
            "タブレット\t10:00:00\nデジカメ\t\t10:00:05\n" +
            "→　補正値は「5」秒と入力")
    }
    
    @IBAction private func cellValueDidChange(_ sender: UIView) {
        guard let cell = tableView.visibleCells.first(where: { $0.accessoryView == sender }),
            let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        let item = list[indexPath.section][indexPath.row]
        
        if let swit = sender as? UISwitch {
            let value = NSNumber(booleanLiteral: swit.isOn).intValue
            switch item {
            case .guide:    arInfo.guide = value
            case .gpsLog:   arInfo.gpsLog = value
            default: break
            }
        }
        
        if let seg = sender as? UISegmentedControl,
            item == .markerType,
            let markerType = Setting.ARInfo.MarkerType(rawValue: seg.selectedSegmentIndex) {
            arInfo.markerType = markerType
        }
    }
}


final class SettingTimeCell: UITableViewCell {
    @IBOutlet private weak var correctedTimeLbl: UILabel!
    
    func updateTime(timeCorrection: Int) {
        let now = Date()
        textLabel?.text = "\(SettingViewController.Item.time.name)\(now.string(.dateTime(.slash)))"
        let corrected = now.addingTimeInterval(TimeInterval(timeCorrection))
        correctedTimeLbl?.text = corrected.string(.dateTime(.slash))
    }
}

class SettingTimeCorrectionCell: SettingNumberCell {
    @IBOutlet private weak var tipBtn: UIButton! {
        didSet {
            tipBtn.imageView?.contentMode = .scaleAspectFit
        }
    }
}

class SettingNumberCell: UITableViewCell {
    
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var stepper: UIStepper!
    @IBOutlet private weak var label: UILabel!
    
    private var item: SettingViewController.Item?
    private var valueChanged: ((SettingViewController.Item, Double) -> Void)?
    
    //マーカ表示可能距離の、選択可能の数字配列（刻みを段階的にする）
    private lazy var optionsForShowFilter: [Double] = {
        let range = Setting.ARInfo.InputLimit.showFilter.range
        return Array(Int(range.lowerBound)...Int(range.upperBound))
            .map({ Double($0) })
            .compactMap { value in
                switch value {
                case 0..<100    where round(value / 10) * 10 == value:     return value
                case 100..<1000 where round(value / 50) * 50 == value:     return value
                case 1000...    where round(value / 100) * 100 == value:   return value
                default: return nil
                }
        }
    }()
    
    @IBAction private func valueChanged(_ sender: AnyObject) {
        guard let item = item, var value = { () -> Double? in
            if sender === slider {
                return Double(slider.value)
            } else if sender === stepper {
                return stepper.value
            }
            return nil
        }() else { return }
        
        value = update(value: value, sender: sender)
        valueChanged?(item, value)
    }
    
    func steup(item: SettingViewController.Item, arInfo: Setting.ARInfo, valueChanged: ((SettingViewController.Item, Double) -> Void)?) {
        self.item = item
        self.valueChanged = valueChanged
        
        guard let format = item.numberFormat,
            let value = { () -> Double? in
                switch item {
                case .timeCorrection:   return Double(arInfo.timeCorrection)
                case .sma:              return Double(arInfo.sma)
                case .markerSize:       return arInfo.markerSize
                case .alphaLevel:       return Double(arInfo.alphaLevel)
                case .showFilter:       return Double(arInfo.showFilter)
                case .maskL:            return Double(arInfo.maskL)
                case .maskR:            return Double(arInfo.maskR)
                default:                return nil
                }
            }()
        else {
            return
        }
        
        if item == .showFilter {
            let max = optionsForShowFilter.count - 1
            slider.minimumValue = 0
            slider.maximumValue = Float(max)
            stepper.minimumValue = 0
            stepper.maximumValue = Double(max)
        } else {
            slider.minimumValue = Float(format.range.lowerBound)
            slider.maximumValue = Float(format.range.upperBound)
            stepper.minimumValue = format.range.lowerBound
            stepper.maximumValue = format.range.upperBound
        }
        stepper.stepValue = Double(format.step)

        let formatted = update(value: value, sender: nil)
        if formatted != value {
            valueChanged?(item, formatted)
        }
    }
    
    private func update(value: Double, sender: AnyObject?)-> Double {
        var value = value               //実際の値
        var controllerValue = value     //slider、stepperの値（showFilterの場合のみ、valueと異なる）
        
        if item == .showFilter {
            if sender == nil {
                let rawValue = value
                value = optionsForShowFilter.first ?? value
                controllerValue = 0
                for (index, option) in optionsForShowFilter.enumerated() {
                    if rawValue < option { break }
                    value = option
                    controllerValue = Double(index)
                }
            } else {
                value = optionsForShowFilter[Int(round(value))]
            }
        } else if let step = item?.numberFormat?.step {
            value = round(value / step) * step
            controllerValue = value
        }
        
        if sender !== slider {
            slider.setValue(Float(controllerValue), animated: true)
        }
        
        if sender !== stepper {
            stepper.value = controllerValue
        }
        
        let number: String
        if item == .some(.alphaLevel) {
            //透明度の表記は0.0~1.0とする
            number = String.localizedStringWithFormat("%.1f", value / 10)
        } else if  item?.numberFormat?.step == 0.1  {
            number = String.localizedStringWithFormat("%.1f", value)
        } else {
            number = String.localizedStringWithFormat("%d", Int(value))
        }
        label.text = number + (item?.numberFormat?.unit ?? "")
        
        return value
    }
}

final class SettingColorCell: UITableViewCell {
    typealias MarkerColor = Setting.ARInfo.MarkerColor
    
    @IBOutlet private weak var btn0: UIButton!
    @IBOutlet private weak var btn1: UIButton!
    @IBOutlet private weak var btn2: UIButton!
    
    private var valueChanged: ((MarkerColor) -> Void)?
    
    @IBAction private func didTouch(_ sender: UIButton) {
        guard !sender.isSelected,
            let value = markerColor(for: sender) else {
            return
        }
        update(value: value)
        valueChanged?(value)
    }
    
    func steup(value: MarkerColor, valueChanged: ((MarkerColor) -> Void)?) {
        self.valueChanged = valueChanged
        update(value: value)
    }
    
    private func markerColor(for button: UIButton) -> MarkerColor? {
        switch button {
        case btn0: return MarkerColor(rawValue: "0")
        case btn1: return MarkerColor(rawValue: "1")
        case btn2: return MarkerColor(rawValue: "2")
        default: return nil
        }
    }
    
    private func update(value: MarkerColor) {
        let selectedBtn: UIButton
        switch value {
        case .red:      selectedBtn = btn0
        case .green:    selectedBtn = btn1
        case .cyan:     selectedBtn = btn2
        }
        
        [btn0, btn1, btn2].forEach { btn in
            if let btn = btn, let color = self.markerColor(for: btn)?.color {
                let selected = btn == selectedBtn
                btn.cornerRadius = selected ? 4 : 0
                btn.borderWidth = selected ? 2 : 4
                
                let borderColor: UIColor = {
                    var hue: CGFloat = 0
                    var saturation: CGFloat = 0
                    var brightness: CGFloat = 0
                    var alpha: CGFloat = 0
                    if color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
                        brightness = brightness * 0.75
                        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
                    } else {
                        return color
                    }
                }()
                btn.borderColor = selected ? borderColor : .white
                btn.backgroundColor = color
            }
        }
    }
}
