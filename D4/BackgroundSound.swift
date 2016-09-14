//
//  BackgroundSound.swift
//  D4
//
//  Created by 文川术 on 4/18/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import AVFoundation

struct BackgroundSound {
	let selected_sound: AVAudioPlayer
	let switchOn_sound: AVAudioPlayer
	let done_sound: AVAudioPlayer

	init() {
		let soundPath_0 = URL(fileURLWithPath: Bundle.main.path(forResource: "Selected", ofType: "m4a")!)
		let soundPath_1 = URL(fileURLWithPath: Bundle.main.path(forResource: "SwitchOn", ofType: "m4a")!)
		let soundPath_2 = URL(fileURLWithPath: Bundle.main.path(forResource: "Done3", ofType: "wav")!)

		selected_sound = try! AVAudioPlayer(contentsOf: soundPath_0)
		switchOn_sound = try! AVAudioPlayer(contentsOf: soundPath_1)
		done_sound = try! AVAudioPlayer(contentsOf: soundPath_2)
	}

	func playSound(_ play: Bool, sound: AVAudioPlayer) {
		sound.stop()
		if play {
			sound.currentTime = 0
			sound.volume = 0.6
			sound.prepareToPlay()
			sound.play()
		}
	}
}

