//
//  AntEffectView.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/09/02.
//

import SwiftUI

struct HuntingEffectView: View {
    @EnvironmentObject var setting: CameraViewModel
    var body: some View {
        ZStack {
            ForEach(0..<setting.numOfEffect, id: \.self) { _ in
                HuntingEffectBody()
                    .environmentObject(setting)
            }
        }
    }
}

struct HuntingEffectBody: View {
    @EnvironmentObject var setting: CameraViewModel
    @ObservedObject var model = HuntingEffect()
    
    @State var timer = Timer.publish(every: 0.01, tolerance: 0, on: .main, in: .common)
    @State var offset: CGSize = .zero
    
    let haptic = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        let speed = setting.animationSpeed * 300
        if model.isAnimating {
            aircraft
                .transition(.asymmetric(insertion: .identity, removal: .opacity))
                .onAppear {
                    fireTimer()
                }
                .onReceive(timer) { (_) in
                    let correctedSpeed = -(1/3) * speed + 1000
                    model.currentTime += 0.01
                    model.alongTrackDistance += model.track.totalArcLength / CGFloat(correctedSpeed)
                    
                    if model.currentTime >= Double(model.randomInterval[0]) - 0.01 &&
                        model.currentTime <= Double(model.randomInterval[0]) + 0.01 {
                        DispatchQueue.main.asyncAfter(
                            deadline: .now() + TimeInterval(model.randomWaiting[0])) {
                            fireTimer()
                        }
                        model.randomWaiting.shuffle()
                        model.randomInterval.shuffle()
                        cancelTimer()
                    }
                    
                    if model.alongTrackDistance > model.track.totalArcLength {
                        withAnimation(.easeIn(duration: 0.5)) {
                            model.isAnimating = false
                            model.isTimerAvailable = true
                            cancelTimer()
                            model.currentTime = 0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                model.alongTrackDistance = CGFloat.zero
                                fireTimer()
                                model.drawPath()
                                model.isAnimating = true
                            }
                        }
                    }
                }
                .onTapGesture {
                    withAnimation(.easeIn(duration: 0.5)) {
                        model.isAnimating = false
                        model.isTimerAvailable = true
                        cancelTimer()
                        model.currentTime = 0
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            model.alongTrackDistance = CGFloat.zero
                            fireTimer()
                            model.drawPath()
                            model.isAnimating = true
                        }
                    }
                    haptic.impactOccurred()
                }
        }
    }
    
    var aircraft: some View {
        let t = model.track.curveParameter(arcLength: model.alongTrackDistance)
        let p = model.track.point(t: t)
        let dp = model.track.derivate(t: t)
        let h = Angle(radians: atan2(Double(dp.dy), Double(dp.dx)))
        return Text(setting.effectObject ?? "🐞")
            .rotationEffect(Angle(degrees: 90))
            .font(.system(size: setting.sizeOfEffect))
            .rotationEffect(h).position(p)
    }
    
    func fireTimer() {
        self.timer = Timer.publish (every: 0.01, on: .main, in: .common)
        self.timer.connect()
    }
    
    func cancelTimer() {
        self.timer.connect().cancel()
    }
}

struct Airview_Previews: PreviewProvider {
    static var previews: some View {
        HuntingEffectView()
    }
}
