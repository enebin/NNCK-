import SwiftUI
import Combine

class HuntingEffect: ObservableObject {
    var track: ParametricCurve
    var path: Path
    var speed: CGFloat
    var object: String
        
    var aircraft: some View {
        let t = track.curveParameter(arcLength: alongTrackDistance)
        let p = track.point(t: t)
        let dp = track.derivate(t: t)
        let h = Angle(radians: atan2(Double(dp.dy), Double(dp.dx)))
        return Text(object)
            .rotationEffect(Angle(degrees: 90))
            .font(.system(size: 35))
            .rotationEffect(h).position(p)
    }
    
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
    private var timer = Timer()
    private var isTimerAvailable = true
    private var currentTime: Double = 0
    private var randomWaiting = Array(stride(from: 0.5, to: 2, by: 0.5))
    private var randomInterval = Array(stride(from: 2.0, to: 3.0, by: 0.5))
    
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

    func play() {
        if isTimerAvailable {
            isAnimating = true

            randomWaiting.shuffle()
            randomInterval.shuffle()
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                self.currentTime += 0.01
                self.alongTrackDistance += self.track.totalArcLength / self.speed
                
                if self.currentTime >= Double(self.randomInterval[0]) - 0.01 &&
                    self.currentTime <= Double(self.randomInterval[0]) + 0.01 {
                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + TimeInterval(self.randomWaiting[0])) {
                        self.play()
                    }
                    self.randomWaiting.shuffle()
                    self.randomInterval.shuffle()
                    self.stop()
                }
                
                if self.alongTrackDistance > self.track.totalArcLength {
                    self.alongTrackDistance = CGFloat.zero
                }
            }
        }
        isTimerAvailable = false
    }
        
    func stop() {
        if !isTimerAvailable {
            timer.invalidate()
        }
        currentTime = 0
        isTimerAvailable = true
    }
    
    func quitAndPlay() {
        self.stop()
        self.alongTrackDistance = CGFloat.zero
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.play()
            self.drawPath()
        }
    }
}
