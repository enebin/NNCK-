import SwiftUI
import Combine

class HuntingEffectModel: ObservableObject {
    let track: ParametricCurve
    let path: Path
    var object: String
        
    var aircraft: some View {
        let t = track.curveParameter(arcLength: alongTrackDistance)
        let p = track.point(t: t)
        let dp = track.derivate(t: t)
        let h = Angle(radians: atan2(Double(dp.dy), Double(dp.dx)))
        return Text(object)
            .rotationEffect(Angle(degrees: 90))
            .font(.largeTitle).rotationEffect(h).position(p)
    }
    
    @Published var alongTrackDistance = CGFloat.zero
    init(object: String) {
        let screenRect = UIScreen.main.bounds
        let leftUp = CGPoint(x: -5, y: 0)
        let rightDown = CGPoint(x: screenRect.maxX, y: screenRect.maxY)
        let leftDown = CGPoint(x: -5, y: screenRect.maxY)
        let rightUp = CGPoint(x: screenRect.maxX, y: 0)
        
        let randCtrlXY = CGPoint(
            x: CGFloat.random(in: (screenRect.maxX..<screenRect.maxX*2)),
            y: CGFloat.random(in: (1..<screenRect.maxY/2)))
        let randCtrlXY2 = CGPoint(
            x: CGFloat.random(in: (-screenRect.maxX*1.5..<0)),
            y: CGFloat.random(in: (screenRect.maxY/2..<screenRect.maxY)))
        
        let from = leftUp
        let to = rightDown
        
        track = Bezier3(from: from, to: to, control1: randCtrlXY, control2: randCtrlXY2)
        path = Path({ (path) in
            path.move(to: from)
            path.addCurve(to: to, control1: randCtrlXY, control2: randCtrlXY2)
        })
        self.object = object
    }
    
    @Published var flying = false
    private var timer = Timer()
    private var isTimerAvailable = true
    private var currentTime: Double = 0
    private var randomSeed = Array(1..<4)

    func play() {
        if isTimerAvailable {
            randomSeed.shuffle()
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                self.currentTime += 0.01
                self.alongTrackDistance += self.track.totalArcLength / 1000.0
                
                if self.currentTime >= Double(self.randomSeed[0]) - 0.01 && self.currentTime <= Double(self.randomSeed[0]) + 0.01 {
                    self.randomSeed.shuffle()
                    self.stop()

                    DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(self.randomSeed[1])) {
                        print(self.randomSeed[0])
                        self.play()
                    }
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
}
