//
//  TrashButtonView.swift
//  VoiceCalc
//
//  Created by Вячеслав Пуханов on 15.12.2019.
//  Copyright © 2019 Вячеслав Пуханов. All rights reserved.
//

import SwiftUI

struct TrashButtonView: View {
    var isRecording: Bool
    var primaryAction: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            self.primaryAction?()
        }) {
            Image(systemName: isRecording ? "multiply" : "trash")
                .font(.largeTitle)
                .padding()
                .foregroundColor(.white)
        }
        .frame(maxWidth: 86)
        .background(Color.black.opacity(0.8))
        .cornerRadius(10.0)
    }
}

struct TrashButtonView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TrashButtonView(isRecording: false)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Not recording")
            TrashButtonView(isRecording: true)
                .previewLayout(.sizeThatFits)
            .previewDisplayName("Recording in progress")
        }
    }
}
