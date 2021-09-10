import SwiftUI

public enum Effects: String, CaseIterable {
    case laser = "레이저"
    case dodgeball = "도망가는 공"
    case floating = "둥둥"
    case realistic = "현실적(심약자 주의)"
    
    func getShape() -> String {
        switch self {
        case .laser:
            return "🔴"
        case .dodgeball:
            return "⚽"
        case .floating:
            return "🌞"
        case .realistic:
            return "🐞"
        }
    }
}
