//
//  ItemsViewController.swift
//  iBeaconDemo
//
//  Created by 曹雪松 on 2018/4/27.
//  Copyright © 2018 曹雪松. All rights reserved.
//

import UIKit
import CoreLocation

let storedItemsKey = "storedItmes"


class ItemsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    var items = [Item]()

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        loadItems()
    }
    
    func loadItems()
    {
        guard let storedItems = UserDefaults.standard.array(forKey: storedItemsKey) as? [Data] else { return }
        for itemData in storedItems {
            guard let item = NSKeyedUnarchiver.unarchiveObject(with: itemData) as? Item else {return}
            items.append(item)
            startMonitoring(item) // 监控每一个Beacon
        }
    }
    
    /// 持久话数据到本地
    func persistItems()
    {
        var itemsData = [Data]()
        for item in items {
            let itemData = NSKeyedArchiver.archivedData(withRootObject: item)
            itemsData.append(itemData)
        }
        UserDefaults.standard.set(itemsData, forKey: storedItemsKey)
        UserDefaults.standard.synchronize()
    }

    func startMonitoring(_ item: Item)
    {
        let region = item.asBeaconRegion()
        locationManager.startMonitoring(for: region)
        locationManager.startRangingBeacons(in: region)
    }
    
    func stopMonitoring(_ item: Item)
    {
        let region = item.asBeaconRegion()
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "segueAdd", let viewController = segue.destination as? AddItemViewController {
            viewController.delegate = self
        }
    }
}
// MARK: AddBeacon
extension ItemsViewController: AddBeacon {
    func addBeacon(item: Item)
    {
        items.append(item)
        
        tableView.beginUpdates()
        let newIndexPath = IndexPath(row: items.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        tableView.endUpdates()
        
        startMonitoring(item) // 开始监控
        persistItems() // 持久化到本地
    }
}
// MARK: UITableViewDataSource
extension ItemsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item") as! ItemCell
        cell.item = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete {
            stopMonitoring(items[indexPath.row])
            tableView.beginUpdates()
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            persistItems()
        }
    }
}
// MARK: UITableViewDelegate
extension ItemsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let item = items[indexPath.row]
        let detailMessage = "UUID: \(item.uuid.uuidString)\nMajor: \(item.majorValue)\nMinor: \(item.minorValue)"
        let detailAlert = UIAlertController(title: "Details", message: detailMessage, preferredStyle: .alert)
        detailAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(detailAlert, animated: true, completion: nil)
    }
}
// MARK: CLLocationManagerDelegate
extension ItemsViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion)
    {
        print("didStartMonitoringFor\(region)")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion)
    {
        print("didRangeBeacons \(beacons.count)个")
        var indexPaths = [IndexPath]()
        for beacon in beacons {
            for row in 0..<items.count {
                // 检测是否是需要监控的beacon
                if items[row] == beacon {
                    items[row].beacon = beacon
                    indexPaths += [IndexPath(row: row, section: 0)]
                }
            }
        }
        
        if let visiblaRows = tableView.indexPathsForVisibleRows {
            let rowsToUpdate = visiblaRows.filter{ indexPaths.contains($0) }
            for row in rowsToUpdate {
                let cell = tableView.cellForRow(at: row) as? ItemCell
                cell?.refreshLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error)
    {
        print("Failed monitoring region\(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Location manager failed \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error)
    {
        print("rangingBeaconsDidFailFor")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion")
    }
}
