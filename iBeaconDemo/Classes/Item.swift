//
//  Item.swift
//  iBeaconDemo
//
//  Created by 曹雪松 on 2018/4/27.
//  Copyright © 2018 曹雪松. All rights reserved.
//

import UIKit
import CoreLocation

/// item 归档/解档的key
struct ItemConstant {
    static let nameKey = "name"
    static let iconKey = "icon"
    static let uuidKey = "uuid"
    static let majorKey = "major"
    static let minorKey = "minor"
}

class Item: NSObject, NSCoding {
    
    let name: String
    let icon: Int
    let uuid: UUID
    let majorValue: CLBeaconMajorValue
    let minorValue: CLBeaconMinorValue
    
    var beacon: CLBeacon? // 关联当前cell 的 beacon实体
    
    init(name: String, icon: Int, uuid: UUID, majorValue: Int, minorValue: Int)
    {
        self.name = name
        self.icon = icon
        self.uuid = uuid
        self.majorValue = UInt16(majorValue)
        self.minorValue  = UInt16(minorValue)
    }
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(name, forKey: ItemConstant.nameKey)
        aCoder.encode(icon, forKey: ItemConstant.iconKey)
        aCoder.encode(uuid, forKey: ItemConstant.uuidKey)
        aCoder.encode(Int(majorValue), forKey: ItemConstant.majorKey)
        aCoder.encode(Int(minorValue), forKey: ItemConstant.minorKey)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        let aName = aDecoder.decodeObject(forKey: ItemConstant.nameKey) as? String
        name = aName ?? ""
        let aUUID = aDecoder.decodeObject(forKey: ItemConstant.uuidKey) as? UUID
        uuid = aUUID ?? UUID()
        icon = aDecoder.decodeInteger(forKey: ItemConstant.iconKey)
        majorValue = UInt16(aDecoder.decodeInteger(forKey: ItemConstant.majorKey))
        minorValue = UInt16(aDecoder.decodeInteger(forKey: ItemConstant.minorKey))
    }
    
    // MARK: 根据beacon配置显示信息
    func nameForProximity(_ proximity: CLProximity) -> String
    {
        switch proximity {
        case .unknown:
            return "Unknown"
        case .immediate:
            return "Immediate"
        case .near:
            return "Near"
        case .far:
            return "Far"
        }
    }
    
    func locationString() -> String
    {
        guard let beacon = beacon else { return "Location: Unknown" }
        
        let proximity = nameForProximity(beacon.proximity)
        let accuray = String(format: "%.2f", beacon.accuracy)
        var location = "Location: \(proximity)"
        if beacon.proximity != .unknown {
            location += "👉 accuracy ✍️\(accuray)m"
        }
        return location
    }
    
    // MARK: 根据模型数据初始化一个BeaconRegion
    func asBeaconRegion() -> CLBeaconRegion {
        return CLBeaconRegion(proximityUUID: uuid, major: majorValue, minor: minorValue, identifier: name)
    }
}

/// 运算符重载: 判断一个Item模型 和一个 Beacon是否相同（即是同一个）
///
/// - Parameters:
///   - item: 模型数据
///   - beacon: Boacon
/// - Returns: 是否是同一个
func ==(item: Item, beacon: CLBeacon) -> Bool
{
    return (item.uuid.uuidString == beacon.proximityUUID.uuidString)
        && (Int(item.majorValue) == Int(truncating: beacon.major))
        && (Int(item.minorValue) == Int(truncating: beacon.minor))
}
