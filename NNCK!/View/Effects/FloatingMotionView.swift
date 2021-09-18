//
//  LadybugEffectView.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/09/01.
//

import SwiftUI

struct FloatingMotionView: View {
    @EnvironmentObject var setting: CameraViewModel

    var body: some View {
        ForEach(0..<setting.numOfEffect, id: \.self) { _ in
            PopEffectBody().environmentObject(setting)
        }
    }
}

struct PopEffectBody: View {
    @EnvironmentObject var setting: CameraViewModel
    @State var offset: CGSize = .zero

    var body: some View {
        let interval: Double = setting.animationSpeed * 1.5

        let timer = Timer.publish(
            every: -(1/5) * interval + Double.random(in: 2...3),       // Second
            tolerance: interval==0 ? 0 : 0.1, // Gives tolerance so that SwiftUI makes optimization
            on: .main,      // Main Thread
            in: .common     // Common Loop
        ).autoconnect()
        
        VStack {
            Text(setting.effectObject ?? Effects.floating.getShape())
                .font(.system(size: setting.sizeOfEffect))
                .offset(offset)
                .transition(.identity)
        }
        .onReceive(timer) { (_) in
            let widthBound = UIScreen.main.bounds.width / 2 - 50
            let heightBound = UIScreen.main.bounds.height / 2 - 50
            let randomOffset = CGSize(
                width: CGFloat.random(in: -widthBound...widthBound),
                height: CGFloat.random(in: -heightBound...heightBound)
            )
            self.offset = randomOffset
        }
        .animation(.linear(duration: 3))
    }
}


struct LadybugEffectView_Previews: PreviewProvider {
    static var previews: some View {
        FloatingMotionView().environmentObject(CameraViewModel())
    }
}
