//
//  AVPlayer.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 8/17/26.
//
import AVFoundation
extension AVPlayer {
    
    public static func dingPlayer() -> AVPlayer {
        guard let url = Bundle.main.url(forResource: "ding", withExtension: "wav") else {
            fatalError("Failed to find sound file.")
        }
        
        let player = AVPlayer(url: url)
        player.volume = 0.3
        return player
    }
}
