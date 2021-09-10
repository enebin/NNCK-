//
//  SoundButtonView.swift
//  NNCK
//
//  Created by 이영빈 on 2021/08/19.
//

import SwiftUI

struct SoundButtonView: View {
    @EnvironmentObject var setting: CameraViewModel
    @EnvironmentObject var viewModel: SoundViewModel
    
    var body: some View {
        HStack {
            ConditionalButton(action: { viewModel.isPlaying ?
                                viewModel.stopSound() : viewModel.playSound()},
                              longPressAction: { viewModel.switchShowSound() },
                              condition: !viewModel.isPlaying,
                              imageName: ["music.note", "music.note"])
            
            Group {
                if viewModel.showSound {
                    ForEach(0..<3) { index in
                        ConditionalButton(
                            action: {
                                viewModel.chooseSound(of: index)
                                viewModel.stopSound()
                            },
                            longPressAction: {},
                            condition: !(viewModel.chosenIndex == index),
                            imageName: ["\(index+1).circle.fill", "\(index+1).circle"])
                    }
                }
            }
            .transition(.move(edge: .leading).combined(with: .opacity))
        }
    }
}

struct SoundButtonView_Previews: PreviewProvider {
    static var previews: some View {
        SoundButtonView()
    }
}
