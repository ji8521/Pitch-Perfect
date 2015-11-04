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
    
    /** Lifecylcle methods **/
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
        // Make sure the stop, pause button is hidden from the start; only enable it once the recording has started
        stop.hidden = true
        pause.hidden = true
        
        // Make sure the recording button is enabled
        record.enabled = true
        
        // Make sure the label is not hidden and the proper text is set
        recording.hidden = false
        recording.text = "Tap to record"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /** Function used to record audio; connected to the mic UI button **/
    @IBAction func recordAudio(sender: UIButton) {
        // Show text "recording in progress"
        recording.text = "Recording in progress"
        
        // Make sure the stop, pause button is visible
        stop.hidden = false
        pause.hidden = false
        
        // Make sure the record button is disabled until the current recording is ongoing
        record.enabled = false
        
        /** Start recording the user's voice **/
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
    
    /** Function used to pause/resume a recording; connected to the button on UI **/
    @IBAction func pauseRecording(sender: UIButton) {
        // If the recorder is currently recording
        if (audioRecorder.recording) {
            // Pause the recorder
            audioRecorder.pause()
            // Change the image of the button to resemble play
            pause.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
            // If it's not recording
        } else {
            // Start the recording again; this should continue from where it was left;  don't use recordAtTime()!
            audioRecorder.record()
            // Set back the pause image for the button
            pause.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
        }
        
    }
    
    /** Called when the recording has been finished; this method is actually saving the file**/
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        // If successful
        if (flag) {
            // Save the recorded audio, by creating a new model object using the constructor
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            
            // Move to the next screen
            performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }
    }
    
    /** This method is used to perform transitions to next views **/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playSoundsVC : PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio!
            playSoundsVC.receivedAudio = data
        }
    }
    
    /** Stop recording and reset state **/
    @IBAction func stopRecording(sender: UIButton) {
        // Change "recording in progress" label to "Tap to record"; make sure it's visible
        recording.hidden = false
        recording.text = "Tap to record"
        
        // Stop the recording session
        audioRecorder.stop()
        
        // Hide stop button
        stop.hidden = true
    }
}

