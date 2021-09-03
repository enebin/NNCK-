//
//  SettingViewModel.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/08/30.
//

import SwiftUI

class SettingViewModel: ObservableObject {
    @Published var pickedColorIndex: Int = 0
    @Published var pickedAnimationIndex: Effects = .laser
    
    let colors = [
        BackgroundColor(description: "유치원 옐로우", foregroundColor: .black, backgroundColor: .yellow),
        BackgroundColor(description: "석탄 블랙", foregroundColor: .white, backgroundColor: .flatblack),
        BackgroundColor(description: "분필 화이트", foregroundColor: .black, backgroundColor: .flatwhite),
        BackgroundColor(description: "용달 블루", foregroundColor: .white, backgroundColor: .flatblue),
        BackgroundColor(description: "쌈무 그린", foregroundColor: .black, backgroundColor: .flatgreen),
        BackgroundColor(description: "소화기 레드", foregroundColor: .white, backgroundColor: .flatred)
    ]
}

public enum Effects: String, CaseIterable {
    case laser = "레이저"
    case dodgeball = "도망가는 공"
    case ladybug = "무당벌레"
    case mouse = "쥐"
    
    func getShape() -> String {
        switch self {
        case .laser:
            return "🔴"
        case .dodgeball:
            return "⚽"
        case .ladybug:
            return "🐞"
        case .mouse:
            return "🐹"
        }
    }
}


struct BackgroundColor {
    let description: Text
    let forgroundColor: Color
    let backgroundColor: Color
    var isChecked: Bool

    
    init(description: String, foregroundColor: Color, backgroundColor: Color) {
        self.description = Text(description).font(.system(size: 15, weight: .bold))
        self.forgroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.isChecked = false
    }
}
