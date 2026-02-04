//
//  Item.swift
//  macroTracker
//
//  Created by Xavier Rudnick on 2/4/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
