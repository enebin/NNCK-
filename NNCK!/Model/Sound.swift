//
//  Sound.swift
//  NNCK
//
//  Created by 이영빈 on 2021/08/18.
//

import Foundation
import AVFoundation
import MediaPlayer
import SwiftUI

struct SoundPlayer {
    // 확장자 무조건 mp3. 무조건 무조건 -> 싫으면 아래에 타입 바꾸기
    // 아래에 디코드 함수도 고쳐줘야됨. 아주 귀찮음.
    var sounds: Array<Sound> = [
        Sound(name: "동료를 부르는 소리",
              description: "고양이가 평소 동료를 부를 때 내는 소리입니다.", id: UUID()),
        Sound(name: "어미 고양이를 찾는 소리",
              description: "새끼 고양이가 어미 고양이를 부를 때 내는 소리입니다.",id: UUID()),
        Sound(name: "어미가 새끼를 찾는 소리",
              description: "어미 고양이가 새끼를 찾을 때 내는 소리입니다.", id: UUID()),
        Sound(name: "짝을 찾는 소리",
              description: "짝짓기 철에 암컷 고양이가 수컷 고양이를 부를 때 내는 소리입니다.", id: UUID()),
    ]
    
    struct Sound: Codable, Identifiable, Hashable {
        // 아래에 init이 있습니다.
        let name: String
        let type: String
        let description: String
        var path: URL?
        var emoji: String?
        var isPlaying: Bool
        var isPaused: Bool
        var duration: Int?
        var id: UUID
        var audioPlayer: AVAudioPlayer?
        
        enum CodingKeys: String, CodingKey {
            case name, type, path, isPlaying, isPaused, description, duration, id
        }
        
        mutating func playSound(infinite: Bool? = nil) {
            if infinite == true {
                self.audioPlayer?.numberOfLoops = -1
            }
            self.audioPlayer?.play()
            self.isPlaying = true
        }
        
        mutating func pauseSound() {
            self.audioPlayer?.pause()
        }
        
        mutating func stopSound() {
            self.audioPlayer?.stop()
            self.audioPlayer?.currentTime = 0
            self.isPlaying = false
        }
        
        mutating func setEmoji(emoji: String) {
            self.emoji = emoji
        }
        
        mutating func getDuration() -> CGFloat {
            return CGFloat((self.audioPlayer?.duration) ?? 0)
        }
        
        func getCurrentTime() -> CGFloat {
            return CGFloat((self.audioPlayer?.currentTime) ?? 0)
        }
        
        private mutating func updateDuration() -> Int {
            return Int(self.getDuration())
        }
        
        init(name: String, description: String, id: UUID) {
            self.name = name
            self.description = description
            
            self.isPlaying = false
            self.isPaused = false
            self.type = "mp3"
            self.id = id
            guard let path = Bundle.main.path(forResource: name, ofType: type) else { return }
            self.audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            self.duration = updateDuration()
        }
        
        // We don't want to decode `fullName` from the JSON
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            description = try container.decode(String.self, forKey: .description)
            type = try container.decode(String.self, forKey: .type)
            path = try container.decode(URL?.self, forKey: .path)
            isPlaying = try container.decode(Bool.self, forKey: .isPlaying)
            isPaused = try container.decode(Bool.self, forKey: .isPaused)
            duration = try container.decode(Int.self, forKey: .duration)
            id = try container.decode(UUID.self, forKey: .id)
        }
        
        // But we want to store `fullName` in the JSON anyhow
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(type, forKey: .type)
            try container.encode(path, forKey: .path)
            try container.encode(description, forKey: .description)
            try container.encode(duration, forKey: .duration)
            try container.encode(id, forKey: .id)
        }
    }
}

//struct MusicPicker: UIViewControllerRepresentable {
//
//    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var player: AudioPlayer
//
//    class Coordinator: NSObject, UINavigationControllerDelegate, MPMediaPickerControllerDelegate {
//
//        var parent: MusicPicker
//
//        init(_ parent: MusicPicker) {
//            self.parent = parent
//        }
//
//        func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
//
//            let selectedSong = mediaItemCollection.items
//
//            if (selectedSong.count) > 0 {
//                let songItem = selectedSong[0]
//                parent.setSong(song: songItem)
//                mediaPicker.dismiss(animated: true, completion: nil)
//            }
//        }
//    }
//
//    func setSong(song: MPMediaItem) {
//        player.setAudioTrack(son
//                                : song)
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<MusicPicker>) -> MPMediaPickerController {
//        let picker = MPMediaPickerController()
//        picker.allowsPickingMultipleItems = false
//        picker.delegate = context.coordinator
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: MPMediaPickerController, context: UIViewControllerRepresentableContext<MusicPicker>) {
//    }
//
//}
