//
//  Colors.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/08/30.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(red: Double(r) / 0xff, green: Double(g) / 0xff, blue: Double(b) / 0xff)
    }
    
    static let flatblack = Color("flatblack")
    static let flatwhite = Color("flatwhite")
    static let flatblue = Color("newblue")
    static let flatgreen = Color("newgreen")
    static let flatred = Color("flatred")
    static let catmint = Color("catmint")
}
