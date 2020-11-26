//
//  ThumbnailViewController.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/07/13.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import UIKit

final class ThumbnailViewController: UITableViewController {
    
    var facilities = [Index.Facility]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return facilities.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThumbnailCell", for: indexPath)
        
        if let thumbnailCell = cell as? ThumbnailCell {
            
            if thumbnailCell.longPress == nil {
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
                thumbnailCell.addGestureRecognizer(longPress)
                thumbnailCell.longPress = longPress
            }
            
            let facility = facilities[indexPath.section]
            thumbnailCell.imgView.image = facility.image
            thumbnailCell.snLbl.text = facility.facility?.serialNumber
            thumbnailCell.statusLbl.text = facility.inspection?.facilityHealth
            thumbnailCell.indexLbl.text = "\(indexPath.section + 1)"
            thumbnailCell.indexLbl.textColor = facility.markerColor
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let sn = facilities[indexPath.section].facility?.serialNumber {
            WebViewController.openFacility(serialNumber: sn, from: self)   
        }
    }
    
    @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {
        guard
            sender.state == .began,
            let cell = tableView.visibleCells.first(where: {
                ($0 as? ThumbnailCell)?.longPress == sender
            }),
            let section = tableView.indexPath(for: cell)?.section,
            let serialNumber = facilities[section].facility?.serialNumber
            else { return }
        
        UpdateLocationViewController.updateFacility(serialNumber: serialNumber, viewController: self, showConfirm: true)
    }
}

class ThumbnailCell: UITableViewCell {
    @IBOutlet weak var imgView:     UIImageView!
    @IBOutlet weak var indexLbl:    UILabel!
    @IBOutlet weak var snLbl:       UILabel!
    @IBOutlet weak var statusLbl:   UILabel!
    weak var longPress: UILongPressGestureRecognizer?
}
