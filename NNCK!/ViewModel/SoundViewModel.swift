//
//  SoundViewMode.swift
//  NNCK
//
//  Created by 이영빈 on 2021/08/19.
//

import SwiftUI

class SoundViewModel: ObservableObject {
    private let model = SoundPlayer()
    typealias Sound = SoundPlayer.Sound
    
    // 사운드 관련 변수
    @Published var showSound = false
    @Published var chosenIndex: Int = 0
    @Published var chosenSound: Sound? = nil
    @Published var isPlaying = false
    
    var sounds: [Sound] {model.sounds}
    
    func switchShowSound() {
        showSound = showSound == true ? false : true
    }

    func chooseSound(of index: Int) {
        stopSound()
        chosenIndex = index
        chosenSound = model.sounds[index]
    }
    
    func playSound() {
        var sound = chosenSound ?? model.sounds[chosenIndex]
        
        sound.playSound(infinite: true)
        self.isPlaying = true
    }
    
    func stopSound() {
        var sound = chosenSound ?? model.sounds[chosenIndex]
        
        sound.stopSound()
        isPlaying = false
    }
}
