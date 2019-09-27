//
//  ButtonSound.swift
//  Jalculator
//
//  Created by Jason Parker on 2019-09-02.
//  Copyright © 2019 Jason Parker. All rights reserved.
//

import SwiftUI
import AVFoundation

class ButtonTapSoundEffect {
    
    var soundPlayer: AVAudioPlayer
    
    init() {
        let url = Bundle.main.url(forResource: "ButtonTapSoundEffect", withExtension: ".mp3")
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: .defaultToSpeaker)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        soundPlayer = try! AVAudioPlayer(contentsOf: url!)
        soundPlayer.volume = 0.5
        soundPlayer.prepareToPlay()
    }
    
    func play() {
        soundPlayer.play()
    }
    
}
