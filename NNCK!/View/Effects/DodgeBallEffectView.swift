//
//  LaserEffectView.swift
//  CatCalling
//
//  Created by 이영빈 on 2021/08/11.
//

import SwiftUI

struct DodgeballEffectView: View {
    @EnvironmentObject var setting: CameraViewModel
    
    var body: some View {
        ZStack {
            ForEach(0..<setting.numOfEffect, id: \.self) { _ in
                Effect()
            }
        }
    }
    
    struct Effect: View {
        @State var offset: CGSize = .zero
        @State var timer: Timer.TimerPublisher = Timer.publish (every: 5, on: .main, in: .common)
        let interval: Double = 3
        
        var body: some View {
            VStack {
                Text(Effects.dodgeball.getShape())
                    .font(.system(size: 35))
                    .padding(5)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        print("Tapped")
                        cancelTimer()
                        let widthBound = UIScreen.main.bounds.width / 2
                        let heightBound = UIScreen.main.bounds.height / 2
                        let randomOffset = CGSize(
                            width: CGFloat.random(in: -widthBound...widthBound),
                            height: CGFloat.random(in: -heightBound...heightBound)
                        )
                        withAnimation {
                            self.offset = randomOffset
                        }
                        fireTimer()
                    }
                    .offset(offset)

            }
            .onAppear {
                fireTimer()
            }
            .onReceive(timer) { (_) in
                let widthBound = UIScreen.main.bounds.width / 2
                let heightBound = UIScreen.main.bounds.height / 2
                let randomOffset = CGSize(
                    width: CGFloat.random(in: -widthBound...widthBound),
                    height: CGFloat.random(in: -heightBound...heightBound)
                )
                withAnimation {
                    self.offset = randomOffset
                }
            }
        }
        
        func fireTimer() {
            self.timer = Timer.publish (every: interval, tolerance: interval==0 ? 0 : 0.1, on: .main, in: .common)
            self.timer.connect()
        }

        func cancelTimer() {
            self.timer.connect().cancel()
        }
    }
}


struct DodgeballEffectView_Previews: PreviewProvider {
    static var previews: some View {
        DodgeballEffectView()
    }
}
