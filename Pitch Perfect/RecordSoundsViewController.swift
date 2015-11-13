//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Jeffrey Isaray on 6/17/15.
//  Copyright (c) 2015 Jeff Isaray. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    
    @IBOutlet weak var record: UIButton!
    @IBOutlet weak var recording: UILabel!
    @IBOutlet weak var stop: UIButton!
    @IBOutlet weak var pause: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
        // Stop and pause buttons are hidden
        stop.hidden = true
        pause.hidden = true
        
        // Record button is visible
        record.enabled = true
        
        // Set label text
        recording.text = "Tap to record"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func recordAudio(sender: UIButton) {
        // Set label to "recording in progress"
        recording.text = "Recording in progress"
        
        // Stop and pause button are visible
        stop.hidden = false
        pause.hidden = false
        
        // Record button is hidden
        record.enabled = false
        
         // Set the path where to save the recording
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        // Get the current date which will be used as the name of the file
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        
        // Combine the directory and filename by putting them into an array
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        // Debugging purposes; print the filepath
        print(filePath)
        
        // Create a session
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        try! audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func pauseRecording(sender: UIButton) {
        // If the recorder is currently recording
        if (audioRecorder.recording) {
            // Pause the recorder
            audioRecorder.pause()
            // Set's pause image to play image
            pause.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
            // If it's not recording
        } else {
            // Starts recording from last location
            audioRecorder.record()
            // Set's image back to pause
            pause.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
        }
        
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        // If recording is successful
        if flag {
            // Save recorded audio by creating a new model object using the constructor
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            
            // Show next screen (segue)
            performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playSoundsVC : PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio!
            playSoundsVC.receivedAudio = data
        }
    }
    
    /** Stop recording and reset state **/
    @IBAction func stopRecording(sender: UIButton) {
        // Change label to "Tap to record" and make it visible
        recording.hidden = false
        recording.text = "Tap to record"
        
        // Stop recording
        audioRecorder.stop()
        
        // Stop button is hidden
        stop.hidden = true
    }
}

