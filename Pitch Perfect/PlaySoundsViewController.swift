//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Jeffrey Isaray on 6/20/15.
//  Copyright (c) 2015 Jeff Isaray. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var stop: UIButton!
    @IBOutlet weak var reset: UIButton!
   
    // Global variables
    var receivedAudio: RecordedAudio!
    var audioPlayerNode: AVAudioPlayerNode!
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Stop button is hidden
        stop.enabled = false
        
        // Get audio file from recorder
        audioEngine = AVAudioEngine()
        audioFile = try! AVAudioFile(forReading: receivedAudio.filePathUrl)
        let session: AVAudioSession = AVAudioSession.sharedInstance()
        try! session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playSlow(sender: UIButton) {
        playAudio(1200, rate: 0.5, reverb: 0, echo: 0)
    }
     
    @IBAction func playFast(sender: UIButton) {
        playAudio(-700, rate: 1.5, reverb: 0, echo: 0)
    }
     
    @IBAction func playChipmunk(sender: UIButton) {
        playAudio(1000, rate: 1, reverb: 0, echo: 0)
    }
     
    @IBAction func playDarthVader(sender: UIButton) {
        playAudio(-1000, rate: 1, reverb: 0, echo: 0)
    }
     
    @IBAction func playEcho(sender: UIButton) {
        playAudio(0, rate: 1, reverb: 0, echo: 0.2)
    }
     
    
    @IBAction func playNormal(sender: UIButton) {
        playAudio(0, rate: 1, reverb: 0, echo: 0)
    }
     
    
    // Play recorded audio using different effects
    private func playAudio(pitch: Float, rate: Float, reverb: Float, echo: Float) {
        // Initialize variables
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        // Set the pitch
        let pitchEffect = AVAudioUnitTimePitch()
        pitchEffect.pitch = pitch
        audioEngine.attachNode(pitchEffect)
        
        // Set the playback rate
        let playbackRateEffect = AVAudioUnitVarispeed()
        playbackRateEffect.rate = rate
        audioEngine.attachNode(playbackRateEffect)
        
        // Set the echo effect on a specific interval
        let echoEffect = AVAudioUnitDelay()
        echoEffect.delayTime = NSTimeInterval(echo)
        audioEngine.attachNode(echoEffect)
        
        // Chain the effects and get output
        audioEngine.connect(audioPlayerNode, to: playbackRateEffect, format: nil)
        audioEngine.connect(playbackRateEffect, to: pitchEffect, format: nil)
        audioEngine.connect(pitchEffect, to: echoEffect, format: nil)
        audioEngine.connect(echoEffect, to: audioEngine.outputNode, format: nil)
        
        // Stop button is visible
        stop.enabled = true
        
        // Stop
        audioPlayerNode.stop()
        
        // Play audio
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        try! audioEngine.start()
        audioPlayerNode.play()
    }
    
    @IBAction func stopAudio(sender: AnyObject) {
            // Stop audio
            audioPlayerNode.stop()
            // Stop button is hidden
            stop.enabled = false
    }
}
