//
//  FacilityListViewController.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/07/14.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import UIKit
import CoreLocation

final class FacilityListViewController: UITableViewController {
    
    enum Sort: Int {
        case serialNumber, dainspectionDate, distance, roadPoint
    }
    
    private var facilities = [Index.Facility]()
    private var header: FacilityHeader?
    private var sort: Sort = .distance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        header = tableView.dequeueReusableCell(withIdentifier: "Header") as? FacilityHeader
        header?.sortButtons.first(where: { $0.index == Sort.distance.rawValue } )?.sort = .ascending
        tableView.tableFooterView = UIView(frame: .zero)
        updateDate()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return facilities.count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FacilityCell", for: indexPath)
        
        if let facilityCell = cell as? FacilityCell {
            let facility = facilities[indexPath.row]
            facilityCell.snLbl.text = facility.facility?.serialNumber
            facilityCell.dateLbl.text = facility.facility?.inspectionDateStr
            
            facilityCell.roadPointLbl.text = facility.facility?.roadPointStr
                .flatMap({ Double($0) })
                .flatMap({ String.localizedStringWithFormat("%.3f", $0) })
            
            facilityCell.distanceLbl.text = facility.distance.flatMap({
                String.localizedStringWithFormat("%.0f", $0)
            })
        }
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        tableView.visibleCells.forEach { cell in
            if tableView.indexPath(for: cell) == indexPath {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
    }
    
    @IBAction private func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction private func showFacility(_ sender: Any) {
        guard let row = tableView.indexPathForSelectedRow?.row,
            let sn = facilities[row].facility?.serialNumber else {
            return
        }
        weak var presenting = presentingViewController
        dismiss(animated: true) {
            if let presenting = presenting {
                WebViewController.openFacility(serialNumber: sn, from: presenting)
            }
        }
    }
    
    @IBAction private func sort(_ sender: SortButton) {
        guard let sort = Sort(rawValue: sender.index) else {
            return
        }
        self.sort = sort
        header?.sortButtons?.forEach {
            if $0 == sender {
                $0.toggle()
            } else {
                $0.sort = nil
            }
        }
        updateDate()
    }
    
    private func updateDate() {
        let sort: (Index.Facility, Index.Facility) -> Bool
        switch self.sort {
        case .serialNumber:
            sort = { f1, f2 in
                f1.facility?.serialNumber ?? ""
                >
                f2.facility?.serialNumber ?? ""
            }

        case .dainspectionDate:
            sort = { f1, f2 in
                f1.facility?.inspectionDateStr?.date(.date(.ja)) ?? Date.distantPast
                >
                f2.facility?.inspectionDateStr?.date(.date(.ja)) ?? Date.distantPast
            }
            
        case .distance:
            sort = { f1, f2 in
                f1.distance ?? .infinity > f2.distance ?? .infinity
            }
            
        case .roadPoint:
            sort = { f1, f2 in
                f1.facility?.roadPointStr.flatMap({ Double($0) }) ?? 0
                >
                f2.facility?.roadPointStr.flatMap({ Double($0) }) ?? 0
            }
        }
        
        facilities = (Index.shared?.facilities ?? []).sorted(by: sort)
        
        if let subSort = header?.sortButtons.first(where:{
            Sort(rawValue: $0.index) == self.sort
        })?.sort, subSort == .ascending {
            facilities.reverse()
        }
        tableView.reloadData()
    }
}


class FacilityCell: UITableViewCell {
    @IBOutlet weak var snLbl:           UILabel!
    @IBOutlet weak var dateLbl:         UILabel!
    @IBOutlet weak var distanceLbl:     UILabel!
    @IBOutlet weak var roadPointLbl:    UILabel!
}

class FacilityHeader: UITableViewCell {
    @IBOutlet var sortButtons: [SortButton]!
}


