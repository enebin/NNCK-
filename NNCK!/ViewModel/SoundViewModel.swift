//
//  SoundViewMode.swift
//  NNCK
//
//  Created by 이영빈 on 2021/08/19.
//

import SwiftUI

class SoundViewModel: ObservableObject {
    private let soundModel = SoundPlayer()
    typealias Sound = SoundPlayer.Sound
    
    // 사운드 관련 변수
    @Published var showSound = false
    @Published var chosenIndex: Int = 0
    @Published var chosenSound: Sound? = nil
    @Published var isPlaying = false
    
    
    func switchShowSound() {
        showSound = showSound == true ? false : true
    }

    func chooseSound(of index: Int) {
        stopSound()
        chosenIndex = index
        chosenSound = soundModel.sounds[index]
    }
    
    func playSound() {
        var sound = chosenSound ?? soundModel.sounds[chosenIndex]
        
        sound.playSound(infinite: true)
        self.isPlaying = true
    }
    
    func stopSound() {
        var sound = chosenSound ?? soundModel.sounds[chosenIndex]
        
        sound.stopSound()
        isPlaying = false
    }
}
