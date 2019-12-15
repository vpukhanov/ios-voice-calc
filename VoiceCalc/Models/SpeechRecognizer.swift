//
//  SpeechRecognizer.swift
//  VoiceCalc
//
//  Created by Вячеслав Пуханов on 15.12.2019.
//  Copyright © 2019 Вячеслав Пуханов. All rights reserved.
//

import Combine
import Speech

class SpeechRecognizerDelegate: NSObject, SFSpeechRecognizerDelegate {}

struct OperationsTokenizer: TokenizerType {
    let unicodeScalars = Set("×+÷/−-".unicodeScalars)
    func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        return unicodeScalars.contains(scalar)
    }
}

class SpeechRecognizer: ObservableObject {
    @Published var isAuthorized = false
    @Published var isActive = false
    @Published var inProgressUtterance = ""
    
    private let operationsCharacterSet: CharacterSet = {
        var set = CharacterSet()
        set.insert(charactersIn: "×+÷/−-")
        return set
    }()
    private var recognizer: SFSpeechRecognizer
    private var recognizerDelegate = SpeechRecognizerDelegate()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var audioEngine = AVAudioEngine()
    
    var onNewUtterance: ((_:[String]) -> Void)? = nil
    
    init(onNewUtterance: ((_:[String]) -> Void)?) {
        self.onNewUtterance = onNewUtterance
        
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru_RU")) else {
            fatalError("Speech recognition is not available on this device.")
        }
        self.recognizer = recognizer
        recognizer.delegate = recognizerDelegate
        
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                self.checkAuthorizationStatus()
            }
        }
        AVAudioSession.sharedInstance().requestRecordPermission { permission in
            DispatchQueue.main.async {
                self.checkAuthorizationStatus()
            }
        }
    }
    
    func toggleRecording() {
        isActive ? stopRecording() : startRecording()
    }
    
    private func checkAuthorizationStatus() {
        isAuthorized =
            SFSpeechRecognizer.authorizationStatus() == .authorized &&
            AVAudioSession.sharedInstance().recordPermission == .granted
    }
    
    private func startRecording() {
        if isActive { return }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            fatalError("Could not create an audio session.")
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            fatalError("Could not start the audio engine.")
        }
        
        startRecognition()
        
        isActive = true
    }
    
    func stopRecording(accept: Bool = true) {
        if !isActive { return }
        
        stopRecognition()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        try? AVAudioSession.sharedInstance().setActive(false)
        
        if accept {
            let tokenizedUtterance = inProgressUtterance.components(matchedWith: .decimalDigits, .letters, operationsCharacterSet)
            onNewUtterance?(tokenizedUtterance)
        }
        inProgressUtterance = ""
        
        isActive = false
    }
    
    private func startRecognition() {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create audio buffer recognition request.")
        }
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            if let result = result {
                isFinal = result.isFinal
                self.inProgressUtterance = result.bestTranscription.formattedString
            }
            if error != nil || isFinal {
                self.stopRecording()
            }
        }
    }
    
    private func stopRecognition() {
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
    }
}
