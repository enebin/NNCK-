//
//  AntEffectView.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/09/02.
//

import SwiftUI

struct HuntingEffectView: View {
    @EnvironmentObject var setting: CameraViewModel
    @ObservedObject var model = HuntingEffect(object: "🐞")
    @State var localTimer = Timer()
    
    var body: some View {
        VStack {
//            AnimatedImage(url: URL(string: "https://media.giphy.com/media/cJpBcOBU3jLTerZepI/giphy.gif?cid=790b7611e306006394715cf5d6614bb25281ff1ee8a9f610&rid=giphy.gif&ct=s"))
//                .resizable()
//                .playbackMode(.bounce)
//                .scaledToFit()
//                .frame(width: 70, height: 70)
            
            ZStack {
                model.path.stroke(style: StrokeStyle(lineWidth: 0.5))
                Text("\(model.isAnimating) "as String)
                if model.isAnimating {
                    model.aircraft
                        .transition(.asymmetric(insertion: .identity, removal: .opacity.combined(with: .scale)))
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.5)) {
                                model.isAnimating = false
                                model.quitAndPlay()
                            }
                        }
                }
            }
            .onAppear {
                model.play()
            }
            .onDisappear {
                model.stop()
            }
        }
    }
    
    func playing() {
        self.model.play()
    }
}


struct Airview_Previews: PreviewProvider {
    static var previews: some View {
        HuntingEffectView()
    }
}
