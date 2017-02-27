//
//  ViewController.swift
//  SoundRecord
//
//  Created by Michael Dyachenko on 27.02.17.
//  Copyright © 2017 Michael Dyachenko. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var recordingSession: AVAudioSession!
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var recordTimer: Timer?
    var keepAliveTimer : Timer?
    var logTimer : Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSession()
        NotificationCenter.default.addObserver(self, selector: #selector(reinstateBackgroundTask), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setUpSession () {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("record allowed")
                    } else {
                        print("record denied")
                    }
                }
            }
        } catch {
            print("record denied")
        }
    }
    
    func reinstateBackgroundTask() {
        recordTimer?.invalidate()
        keepAliveTimer?.invalidate()
        logTimer?.invalidate()
        
        recordTimer = Timer.scheduledTimer(timeInterval: 300.0, target: self,
                                           selector: #selector(makeRecord), userInfo: nil, repeats: true)
        keepAliveTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self,
                                              selector: #selector(playKeepAliveSound), userInfo: nil, repeats: true)
//        logTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self,
//                                      selector: #selector(showLog), userInfo: nil, repeats: true)
        
        if backgroundTask == UIBackgroundTaskInvalid {
            registerBackgroundTask()
        }
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }

    func makeRecord (){
        startRecording()
    }
    
    
    
    func startRecording() {
        print("Recodring")
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        print(audioFilename)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record(forDuration: 10)
        } catch {
            
        }
    }
    
    func playKeepAliveSound() {
        keepAwakeCallback()
    }
    
    func keepAwakeCallback () {
        print("keep alive")
        let audioPlayer = try! AVAudioPlayer(contentsOf: URL(string: Bundle.main.path(forResource: "keepawake", ofType: "wav")!)!)
        audioPlayer.play()

    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
//    func showLog () {
//        print("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
//    }
    
// to play recorded audio via inner speaker
    
//    func playRecord () {
//        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
//        do {
//            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
//            audioPlayer.volume = 1.0
//            audioPlayer.play()
//        }
//        catch {
//            print("error")
//        }
//    }
//    
//    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
//        print("done!")
//        playRecord()
//    }
//    

}

