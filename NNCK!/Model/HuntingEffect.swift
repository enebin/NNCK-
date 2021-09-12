import SwiftUI
import Combine

class HuntingEffect: ObservableObject {
    @Published var alongTrackDistance = CGFloat.zero
    @Published var isAnimating = true
    
    var timer = Timer()
    var isTimerAvailable = true
    var currentTime: Double = 0
    var randomWaiting = Array(stride(from: 0.5, to: 2, by: 0.5))
    var randomInterval = Array(stride(from: 2.0, to: 3.0, by: 0.5))
    
    var track: ParametricCurve
    var path: Path
    var speed: CGFloat
    let A, B, C, D, all, LR, RL : [CGPoint]
    let pointSets: [PointSets]
    
    func drawPath() {
        let p = pointSets.randomElement()!
        
        let from = p.from.randomElement()!
        let to = p.to.randomElement()!
        let ctrl1 = p.ctrl1
        let ctrl2 = p.ctrl2
        
        self.track = Bezier3(from: from, to: to, control1: ctrl1, control2: ctrl2)
        self.path = Path({ (path) in
            path.move(to: from)
            path.addCurve(to: to, control1: ctrl1, control2: ctrl2)
        })
    }
    
    func setSpeed(_ speed: CGFloat) {
        self.speed = speed
    }
    
    init() {
        let X = UIScreen.main.bounds.maxX
        let Y = UIScreen.main.bounds.maxY
        
        // ↖
        let AB = CGPoint(x: 10, y: 0)
        let AC = CGPoint(x: 0, y: 10)
        self.A = [AB, AC]
        
        // ↘
        let DB = CGPoint(x: X, y: Y-10)
        let DC = CGPoint(x: X-10, y: Y)
        self.D = [DB, DC]
        
        // ↗
        let BA = CGPoint(x: X-10, y: 0)
        let BD = CGPoint(x: X, y: 10)
        self.B = [BA, BD]
        
        // ↙
        let CD = CGPoint(x: 10, y: Y)
        let CA = CGPoint(x: 0, y: Y-10)
        self.C = [CD, CA]
        
        self.all = [AB, AC, DB, DC, BA, BD, CD, CA]
        
        // ↖↘
        let AD = CGPoint(
            x: CGFloat.random(in: (-X*1.5..<0)),
            y: CGFloat.random(in: (1..<Y/2)))
        let DA = CGPoint(
            x: CGFloat.random(in: (X..<X*2)),
            y: CGFloat.random(in: (Y/2..<Y)))
        self.LR = [AD, DA]
        
        // ↙↗
        let BC = CGPoint(
            x: CGFloat.random(in: (X..<X*2)),
            y: CGFloat.random(in: (1..<Y/2)))
        let CB = CGPoint(
            x: CGFloat.random(in: (-X*1.5..<0)),
            y: CGFloat.random(in: (Y/2..<Y)))
        self.RL = [BC, CB]
        
        let ADpath = PointSets(from: A,
                               to: D,
                               ctrl1: RL[0],
                               ctrl2: RL[1])
        
        let DApath = PointSets(from: D,
                               to: A,
                               ctrl1: RL[1],
                               ctrl2: RL[0])
        
        let BCpath = PointSets(from: B,
                               to: C,
                               ctrl1: LR[0],
                               ctrl2: LR[1])
        
        let CBpath = PointSets(from: C,
                               to: B,
                               ctrl1: LR[1],
                               ctrl2: LR[0])
        
        self.pointSets = [ADpath, DApath, BCpath, CBpath]
        let p = pointSets.randomElement()!
        
        let from = p.from.randomElement()!
        let to = p.to.randomElement()!
        let ctrl1 = p.ctrl1
        let ctrl2 = p.ctrl2
        
        self.track = Bezier3(from: from, to: to, control1: ctrl1, control2: ctrl2)
        self.path = Path({ (path) in
            path.move(to: from)
            path.addCurve(to: to, control1: ctrl1, control2: ctrl2)
        })
        
        self.speed = 1000.0
    }
}

struct PointSets {
    let from: [CGPoint]
    let to: [CGPoint]
    let ctrl1: CGPoint
    let ctrl2: CGPoint
}
