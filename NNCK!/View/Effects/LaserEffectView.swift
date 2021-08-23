//
//  LaserEffectView.swift
//  CatCalling
//
//  Created by 이영빈 on 2021/08/11.
//

import SwiftUI

struct LaserEffectView: View {
    @EnvironmentObject var setting: CameraViewModel
    @State var offset: CGSize = .zero

    var body: some View {
        let interval = setting.animationSpeed

        let timer = Timer.publish(
            every: -(1/5) * interval + 2,       // Second
            tolerance: interval==0 ? 0 : 0.1, // Gives tolerance so that SwiftUI makes optimization
            on: .main,      // Main Thread
            in: .common     // Common Loop
        ).autoconnect()
        
        VStack {
            Circle()
                .foregroundColor(.red)
                .frame(width: 25, height: 25, alignment: .center)
                .offset(offset)
        }.onReceive(timer) { (_) in
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
}


struct LaserEffectView_Previews: PreviewProvider {
    static var previews: some View {
        LaserEffectView()
    }
}