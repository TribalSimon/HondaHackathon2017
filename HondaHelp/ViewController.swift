//
//  ViewController.swift
//  HondaHelp
//
//  Created by Bryan Norden on 11/27/17.
//  Copyright © 2017 TribalScale. All rights reserved.
//

import AVFoundation
import UIKit

class ViewController: UIViewController {
    
    private lazy var socket: SocketIOClient = {
        
        return socketManager.defaultSocket
        
    }()
    
    private lazy var socketManager: SocketManager = {
        
        return SocketManager(socketURL: URL(string:"https://protected-ocean-43147.herokuapp.com")!, config: [.log(true), .compress])
        
    }()
    
    private lazy var speechSynthesizer: AVSpeechSynthesizer = {
        
        let speechSynthesizer = AVSpeechSynthesizer()
//        speechSynthesizer.delegate = self
        
        return speechSynthesizer
        
    }()
    
    private lazy var voiceToUse: AVSpeechSynthesisVoice = {
        
        
        for voice in AVSpeechSynthesisVoice.speechVoices() {
            
            if voice.name == "Samantha (Enhanced)" && voice.quality == .enhanced {
                return voice
            }
            
        }
        
        return AVSpeechSynthesisVoice()
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        socket.on("accidentReport", callback: { data, ackEmitter in
            
            print(data)
            
        })
        
        socket.connect()
        
    }
    
    private func sendCrashNotification() {
        
        let crashJSON: [String: Any] = ["latitude": 34.0391623, "longitude": -118.2435846]
        
        socket.emit("accidentReport", with: [crashJSON])
        
    }

}

// MARK: - IBAction

extension ViewController {
    
    @IBAction private func hiddenCrashButtonTapped(_ sender: UIButton) {
        
        sendCrashNotification()
        
    }
    
    @IBAction private func micButtonTapped(_ sender: UIButton) {
        
        let utterance = AVSpeechUtterance(string: "Do you need assistance?")
        utterance.voice = voiceToUse
        
        speechSynthesizer.speak(utterance)
        
        // TODO: if so send crash notification
        
//        sendCrashNotification()
        
    }
    
}

