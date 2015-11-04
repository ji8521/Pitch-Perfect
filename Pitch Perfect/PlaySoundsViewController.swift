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

    // references to UI elements
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
        
        // Make sure the stop button is not enabled from the start
        stop.enabled = false
        
        // Get the audio file from recorder
        audioEngine = AVAudioEngine()
        audioFile = try! AVAudioFile(forReading: receivedAudio.filePathUrl)
        let session: AVAudioSession = AVAudioSession.sharedInstance()
        try! session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /** ***************************** **/
     /// Normal values
     /// =================
     /// Playback rate: 1
     /// Pitch:         0
     /// Reverb:        0
     /// Echo/Interval: 0
     ///
     ///
     /// Ranges values
     /// =================
     /// Playback rate: 0.25 to 4
     /// Pitch:         -2400 to 2400
     /// Reverb:        0 to 100
     /// Echo/Interval: 0 to 2
     /** ***************************** **/
     
     // Due to the fact when changing the rate of playback using the AVAudioUnitVarispeed class,
     // it resemplas the audio and modifies both the rate AND the pitch. This is due to the fact,
     // that pitch is measured in "cents" (used in measuring musical instruments) and therefore as
     // you change the rate, the tone is also changing, thus mimicing a more real effect of the rate.
     // As the pitch can be defined as pitch = 1200.0 * log2(rate), we can calculate that with the
     // value 1.5 we need to put the pitch -700 cents back, and with 0.5, 1200 cents above 0 to neutralize this effect.
     //
     // See: https://developer.apple.com/library/prerelease/ios/documentation/AVFoundation/Reference/AVAudioUnitVarispeed_Class/index.html#//apple_ref/occ/instp/AVAudioUnitVarispeed/rate
     
    
    
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
     
    
    /** Function used to play a recorded audio using different parameters/effects **/
    private func playAudio(pitch : Float, rate: Float, reverb: Float, echo: Float) {
        // Initialize variables
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        // Setting the pitch
        let pitchEffect = AVAudioUnitTimePitch()
        pitchEffect.pitch = pitch
        audioEngine.attachNode(pitchEffect)
        
        // Setting the platback-rate
        let playbackRateEffect = AVAudioUnitVarispeed()
        playbackRateEffect.rate = rate
        audioEngine.attachNode(playbackRateEffect)
        
        // Setting the reverb effect
        let reverbEffect = AVAudioUnitReverb()
        reverbEffect.loadFactoryPreset(AVAudioUnitReverbPreset.Cathedral)
        reverbEffect.wetDryMix = reverb
        audioEngine.attachNode(reverbEffect)
        
        // Setting the echo effect on a specific interval
        let echoEffect = AVAudioUnitDelay()
        echoEffect.delayTime = NSTimeInterval(echo)
        audioEngine.attachNode(echoEffect)
        
        // Chain all these up, ending with the output
        audioEngine.connect(audioPlayerNode, to: playbackRateEffect, format: nil)
        audioEngine.connect(playbackRateEffect, to: pitchEffect, format: nil)
        audioEngine.connect(pitchEffect, to: reverbEffect, format: nil)
        audioEngine.connect(reverbEffect, to: echoEffect, format: nil)
        audioEngine.connect(echoEffect, to: audioEngine.outputNode, format: nil)
        
        // enable the Stop button
        stop.enabled = true
        
        // Good practice to stop before starting
        audioPlayerNode.stop()
        
        // Play the audio file
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        try! audioEngine.start()
        audioPlayerNode.play()
    }
    
    /** Function used to stop the audio; connected to the UI element **/
    
    @IBAction func stopAudio(sender: AnyObject) {
            // Stop any audio
            audioPlayerNode.stop()
            // Disable the stop button
            stop.enabled = false
    }
}
