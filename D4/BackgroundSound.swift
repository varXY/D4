//
//  BackgroundSound.swift
//  D4
//
//  Created by 文川术 on 4/18/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import AVFoundation

struct BackgroundSound {
	var selected_sound: AVAudioPlayer
	var switchOn_sound: AVAudioPlayer
	var done_sound: AVAudioPlayer

	init() {
		let soundPath_0 = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Selected", ofType: "m4a")!)
		let soundPath_1 = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("SwitchOn", ofType: "m4a")!)
		let soundPath_2 = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Done3", ofType: "wav")!)

		selected_sound = try! AVAudioPlayer(contentsOfURL: soundPath_0)
		switchOn_sound = try! AVAudioPlayer(contentsOfURL: soundPath_1)
		done_sound = try! AVAudioPlayer(contentsOfURL: soundPath_2)
	}

	func playSound(play: Bool, sound: AVAudioPlayer) {
		sound.stop()
		if play {
			sound.currentTime = 0
			sound.volume = 0.65
			sound.prepareToPlay()
			sound.play()
		}
	}
}

