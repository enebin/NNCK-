import SwiftUI
import Combine

class HuntingEffect: ObservableObject {
    var track: ParametricCurve
    var path: Path
    var speed: CGFloat
    var object: String
        
   
    
    @Published var alongTrackDistance = CGFloat.zero
    init(object: String) {
        let X = UIScreen.main.bounds.maxX
        let Y = UIScreen.main.bounds.maxY
        
        // ↖
        let AB = CGPoint(x: 10, y: 0)
        let AC = CGPoint(x: 0, y: 10)
        let A = [AB, AC]
        
        // ↘
        let DB = CGPoint(x: X, y: Y-10)
        let DC = CGPoint(x: X-10, y: Y)
        let D = [DB, DC]
        
        // ↗
        let BA = CGPoint(x: X-10, y: 0)
        let BD = CGPoint(x: X, y: 10)
        let B = [BA, BD]
        
        // ↙
        let CD = CGPoint(x: 10, y: Y)
        let CA = CGPoint(x: 0, y: Y-10)
        let C = [CD, CA]
        let all = [AB, AC, DB, DC, BA, BD, CD, CA]
        
        // ↖↘
        let AD = CGPoint(
            x: CGFloat.random(in: (-X*1.5..<0)),
            y: CGFloat.random(in: (1..<Y/2)))
        let DA = CGPoint(
            x: CGFloat.random(in: (X..<X*2)),
            y: CGFloat.random(in: (Y/2..<Y)))
        let LR = [AD, DA]
        
        // ↙↗
        let BC = CGPoint(
            x: CGFloat.random(in: (X..<X*2)),
            y: CGFloat.random(in: (1..<Y/2)))
        let CB = CGPoint(
            x: CGFloat.random(in: (-X*1.5..<0)),
            y: CGFloat.random(in: (Y/2..<Y)))
        let RL = [BC, CB]
        
        let allRL = [AD, DA, BC, CB]
//        let pointSets = [[leftUp, rightDown], [leftDown, rightUp],
//                         [rightUp, leftDown], [rightDown, leftUp]]
//        let ctrlPointSets = [[rightUpCtrl, lefdDownCtrl], [rightDownCtrl, leftUpCtrl],
//                             [leftUpCtrl, rightDownCtrl], [lefdDownCtrl, rightUpCtrl]]
//
//        let from = pointSets[0][0]
//        let to = pointSets[0][1]
//        let ctrl1 = ctrlPointSets[0][0]
//        let ctrl2 = ctrlPointSets[0][1]
        
        let randInt1 = Int.random(in: 0..<2)
        let randInt2 = (randInt1 != 0) ? 0 : 1
        let from = A[0]
        let to = D[0]
        let ctrl1 = LR[0]
        let ctrl2 = LR[1]
        
        self.track = Bezier3(from: from, to: to, control1: ctrl1, control2: ctrl2)
        self.path = Path({ (path) in
            path.move(to: from)
            path.addCurve(to: to, control1: ctrl1, control2: ctrl2)
        })

        self.object = object
        self.speed = 1000.0
    }
    
    @Published var isAnimating = true
    var timer = Timer()
    var isTimerAvailable = true
    var currentTime: Double = 0
    var randomWaiting = Array(stride(from: 0.5, to: 2, by: 0.5))
    var randomInterval = Array(stride(from: 2.0, to: 3.0, by: 0.5))
    
    func setSpeed(_ speed: CGFloat) {
        self.speed = speed
    }
    
    func drawPath() {
        let X = UIScreen.main.bounds.maxX
        let Y = UIScreen.main.bounds.maxY
        
        // ↖
        let AB = CGPoint(x: 10, y: 0)
        let AC = CGPoint(x: 0, y: 10)
        let A = [AB, AC]
        
        // ↘
        let DB = CGPoint(x: X, y: Y-10)
        let DC = CGPoint(x: X-10, y: Y)
        let D = [DB, DC]
        
        // ↗
        let BA = CGPoint(x: X-10, y: 0)
        let BD = CGPoint(x: X, y: 10)
        let B = [BA, BD]
        
        // ↙
        let CD = CGPoint(x: 10, y: Y)
        let CA = CGPoint(x: 0, y: Y-10)
        let C = [CD, CA]
        
        // ↖↘
        let AD = CGPoint(
            x: CGFloat.random(in: (-X*1.5..<0)),
            y: CGFloat.random(in: (1..<Y/2)))
        let DA = CGPoint(
            x: CGFloat.random(in: (X..<X*2)),
            y: CGFloat.random(in: (Y/2..<Y)))
        let LR = [AD, DA]
        
        // ↙↗
        let BC = CGPoint(
            x: CGFloat.random(in: (X..<X*2)),
            y: CGFloat.random(in: (1..<Y/2)))
        let CB = CGPoint(
            x: CGFloat.random(in: (-X*1.5..<0)),
            y: CGFloat.random(in: (Y/2..<Y)))
        let RL = [BC, CB]
        
        let from = AB
        let to = DB
        let ctrl1 = BC
        let ctrl2 = CB
        
        self.track = Bezier3(from: from, to: to, control1: ctrl1, control2: ctrl2)
        self.path = Path({ (path) in
            path.move(to: from)
            path.addCurve(to: to, control1: ctrl1, control2: ctrl2)
        })
    }
}
