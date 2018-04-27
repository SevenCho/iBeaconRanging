//
//  Icons.swift
//  iBeaconDemo
//
//  Created by 曹雪松 on 2018/4/27.
//  Copyright © 2018 曹雪松. All rights reserved.
//

import Foundation
import UIKit

enum Icons: Int {
    case bag = 0
    case brain
    case cat
    case glasses
    case key
    case wallet
    
    func image() -> UIImage?
    {
        return UIImage(named: "\(self.name())")
    }
    
    func name() -> String
    {
        switch self {
        case .bag: return "Icon_Bag"
        case .brain: return "Icon_Brain"
        case .cat: return "Icon_Cat"
        case .glasses: return "Icon_Glasses"
        case .key: return "Icon_Key"
        case .wallet: return "Icon_Wallet"
        }
    }
    
    static func icon(forTag tag: Int) -> Icons
    {
        return Icons(rawValue: tag) ?? .bag
    }
    
    /// 返回枚举的所有值 按从小到大排序
    static let allIcons: [Icons] = {
        var all = [Icons]()
        var index: Int = 0
        while let icon = Icons(rawValue: index) {
            all += [icon]
            index += 1
        }
        return all.sorted{ $0.rawValue < $1.rawValue }
    }()
}
