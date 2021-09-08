import SwiftUI

public enum Effects: String, CaseIterable {
    case laser = "레이저"
    case dodgeball = "도망가는 공"
    case ladybug = "무당벌레"
    case realistic = "현실적인 모션 (심약자 주의)"
    
    func getShape() -> String {
        switch self {
        case .laser:
            return "🔴"
        case .dodgeball:
            return "⚽"
        case .ladybug:
            return "🐞"
        case .realistic:
            return "🐞"
        }
    }
}
