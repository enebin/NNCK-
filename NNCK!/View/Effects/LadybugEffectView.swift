//
//  LadybugEffectView.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/09/01.
//

import SwiftUI

struct LadybugEffectView: View {
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
            Image("ladybug")
                .resizable()
                .frame(width: 25, height: 25, alignment: .center)
                .offset(offset)
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
}


struct LadybugEffectView_Previews: PreviewProvider {
    static var previews: some View {
        LadybugEffectView()
    }
}
