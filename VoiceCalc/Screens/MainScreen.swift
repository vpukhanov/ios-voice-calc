//
//  MainScreen.swift
//  VoiceCalc
//
//  Created by Вячеслав Пуханов on 15.12.2019.
//  Copyright © 2019 Вячеслав Пуханов. All rights reserved.
//

import SwiftUI

struct MainScreen: View {
    @ObservedObject var model: CalculatorModel
    @ObservedObject var recognizer: SpeechRecognizer
    
    init(model: CalculatorModel) {
        self.model = model
        self.recognizer = SpeechRecognizer(
            onNewUtterance: { utterance in
                model.process(utterance: utterance)
            }
        )
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Main results view
            ScrollView {
                ResultsStackView(model: model)
                    .padding(.horizontal)
                
                // This adds some padding so content does not
                // get hidden behind the button
                Rectangle()
                    .frame(height: 60)
                    .opacity(0)
            }
            
            // Recording button
            VStack {
                Spacer()
                HStack {
                    RecordingButtonView(
                        hasAuthorization: recognizer.isAuthorized,
                        isRecording: recognizer.isActive,
                        requestAuthorizationAction: {
                            self.recognizer.requestAuthorization()
                        },
                        toggleRecordingAction: {
                            self.recognizer.toggleRecording()
                        }
                    )
                        .shadow(radius: 2)
                    if recognizer.isActive || model.isResetable {
                        TrashButtonView(isRecording: recognizer.isActive, primaryAction: {
                            if self.recognizer.isActive {
                                self.recognizer.stopRecording(accept: false)
                            } else {
                                self.model.reset()
                            }
                        })
                            .shadow(radius: 2)
                    }
                }
            }
            .padding(.horizontal)
            
            // Utterance in progress
            VStack {
                Spacer()
                Text(recognizer.inProgressUtterance)
                    .frame(maxWidth: .infinity)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 64)
        }
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen(model: CalculatorModel.debugModel)
    }
}
