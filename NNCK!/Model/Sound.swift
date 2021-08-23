//
//  Sound.swift
//  NNCK
//
//  Created by 이영빈 on 2021/08/18.
//

import Foundation
import AVFoundation

struct SoundPlayer {
    /// TODO: -오토스캔할 수 있게 바꿔놓기
    /// TODO: -로컬 파일 추가 가능하게 바꿔놓기
    
    var sounds: Array<Sound> = [
        Sound(name: "catsound_clipped", id: UUID()),
        Sound(name: "bird-clipped", id: UUID()),
        Sound(name: "catsound_clipped2", id: UUID())
    ]
    
    struct Sound: Codable, Identifiable, Hashable {
        let name: String
        let type: String
        var path: URL?
        var description: String?
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
        
        init(name: String, id: UUID) {
            self.name = name
            self.isPlaying = false
            self.isPaused = false
            self.type = "mp4"
            self.id = id
            guard let path = Bundle.main.path(forResource: name, ofType: type) else { return }
            self.audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            self.duration = updateDuration()
        }
        
        // We don't want to decode `fullName` from the JSON
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            type = try container.decode(String.self, forKey: .type)
            path = try container.decode(URL?.self, forKey: .path)
            isPlaying = try container.decode(Bool.self, forKey: .isPlaying)
            isPaused = try container.decode(Bool.self, forKey: .isPaused)
            description = try container.decode(String?.self, forKey: .description)
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
