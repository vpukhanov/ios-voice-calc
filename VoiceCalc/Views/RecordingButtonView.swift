//
//  RecordingButtonView.swift
//  VoiceCalc
//
//  Created by Вячеслав Пуханов on 15.12.2019.
//  Copyright © 2019 Вячеслав Пуханов. All rights reserved.
//

import SwiftUI

struct RecordingButtonView: View {
    var hasAuthorization: Bool
    var isRecording: Bool
    
    var requestAuthorizationAction: (() -> Void)? = nil
    var toggleRecordingAction: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            if !self.hasAuthorization {
                self.requestAuthorizationAction?()
            } else {
                self.toggleRecordingAction?()
            }
        }) {
            Image(systemName: hasAuthorization ? "mic" : "questionmark")
                .font(.largeTitle)
                .padding()
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .background(
            hasAuthorization
                ? (isRecording ? Color.red : Color.blue)
                : Color.gray)
        .cornerRadius(10.0)
    }
}

struct RecordingButtonView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RecordingButtonView(hasAuthorization: true, isRecording: true)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Has authorization, recording")
            RecordingButtonView(hasAuthorization: true, isRecording: false)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Has authorization, idle")
            RecordingButtonView(hasAuthorization: false, isRecording: false)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("No authorization")
        }
    }
}
