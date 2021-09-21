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
            ConditionalButton(action: {
                viewModel.isPlaying ?
                    viewModel.stopSound() : viewModel.playSound()
                if setting.soundAlertIsChecked == false && viewModel.isPlaying == true {
                    setting.soundAlert = true
                }
            },
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
        .alert(isPresented: $setting.soundAlert, content: {
            Alert(title: Text("안내"), message: Text("기기의 무음 모드를 해제하지 않으면 소리가 들리지 않아요!"), primaryButton: .default(Text("Ok")), secondaryButton: .destructive(Text("다시 보지 않기"), action: {
                setting.soundAlertIsChecked = true
            }) )
        })
    }
}

struct SoundButtonView_Previews: PreviewProvider {
    static var previews: some View {
        SoundButtonView()
    }
}
