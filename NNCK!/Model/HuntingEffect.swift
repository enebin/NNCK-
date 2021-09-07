import SwiftUI
import Combine

class HuntingEffect: ObservableObject {
    let track: ParametricCurve
    let path: Path
    let routes: [Path]
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
        let screenRect = UIScreen.main.bounds
        
        let leftUp = CGPoint(x: -5, y: 10)
        let rightDown = CGPoint(x: screenRect.maxX, y: screenRect.maxY)
        let leftDown = CGPoint(x: -5, y: screenRect.maxY)
        let rightUp = CGPoint(x: screenRect.maxX, y: 0)
        
        let leftUpCtrl = CGPoint(//
            x: CGFloat.random(in: (-screenRect.maxX*1.5..<0)),
            y: CGFloat.random(in: (1..<screenRect.maxY/2)))
        let lefdDownCtrl = CGPoint(//
            x: CGFloat.random(in: (-screenRect.maxX*1.5..<0)),
            y: CGFloat.random(in: (screenRect.maxY/2..<screenRect.maxY)))
        let rightUpCtrl = CGPoint(//
            x: CGFloat.random(in: (screenRect.maxX..<screenRect.maxX*2)),
            y: CGFloat.random(in: (1..<screenRect.maxY/2)))
        let rightDownCtrl = CGPoint(
            x: CGFloat.random(in: (screenRect.maxX..<screenRect.maxX*2)),
            y: CGFloat.random(in: (screenRect.maxY/2..<screenRect.maxY)))
        
        let pointSets = [[leftUp, rightDown], [leftDown, rightUp],
                         [rightUp, leftDown], [rightDown, leftUp]]
        let ctrlPointSets = [[rightUpCtrl, lefdDownCtrl], [rightDownCtrl, leftUpCtrl],
                             [leftUpCtrl, rightDownCtrl], [lefdDownCtrl, rightUpCtrl]]
        
        let from = pointSets[0][0]
        let to = pointSets[0][1]
        let ctrl1 = ctrlPointSets[0][0]
        let ctrl2 = ctrlPointSets[0][1]
        
        track = Bezier3(from: from, to: to, control1: ctrl1, control2: ctrl2)
        path = Path({ (path) in
            path.move(to: from)
            path.addCurve(to: to, control1: ctrl1, control2: ctrl2)
        })
        self.object = object
        self.speed = 1000.0
        self.routes = [Path]()
    }
    
    private var timer = Timer()
    private var isTimerAvailable = true
    private var currentTime: Double = 0
    private var randomWaiting = Array(stride(from: 0.5, to: 2, by: 0.5))
    private var randomInterval = Array(stride(from: 2.0, to: 3.0, by: 0.5))
    
    func draw() {
        
    }

    func play() {
        if isTimerAvailable {
            randomWaiting.shuffle()
            randomInterval.shuffle()
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                self.currentTime += 0.01
                self.alongTrackDistance += self.track.totalArcLength / self.speed
                
                if self.currentTime >= Double(self.randomInterval[0]) - 0.01 &&
                    self.currentTime <= Double(self.randomInterval[0]) + 0.01 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(self.randomWaiting[0])) {
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
        alongTrackDistance = CGFloat.zero
        currentTime = 0
        isTimerAvailable = true
        self.play()
    }
}
