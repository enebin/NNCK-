//
//  LaserEffectView.swift
//  CatCalling
//
//  Created by 이영빈 on 2021/08/11.
//

import SwiftUI

struct LaserEffectView: View {
    @EnvironmentObject var setting: CameraViewModel

    var body: some View {
        ZStack {
            ForEach(0..<setting.numOfEffect, id: \.self) { _ in
                EffectBody()
                    .environmentObject(setting)
            }
        }
    }
}

struct EffectBody: View {
    @EnvironmentObject var setting: CameraViewModel
    @State var offset: CGSize = .zero
    
    var body: some View {
        let interval = setting.animationSpeed
        let timer = Timer.publish(
            every: -(1/5) * interval + Double.random(in: 2...3),       // Second
            tolerance: interval==0 ? 0 : 0.1, // Gives tolerance so that SwiftUI makes optimization
            on: .main,      // Main Thread
            in: .common     // Common Loop
        ).autoconnect()
        
        VStack {
            if setting.effectObject == nil {
                Circle()
                    .foregroundColor(.red)
                    .frame(width: setting.sizeOfEffect-10, height: setting.sizeOfEffect-10, alignment: .center)
                    .offset(offset)
            } else {
                Text(setting.effectObject!)
                    .font(.system(size: setting.sizeOfEffect))
                    .offset(offset)
            }
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


struct LaserEffectView_Previews: PreviewProvider {
    static var previews: some View {
        LaserEffectView()
    }
}
