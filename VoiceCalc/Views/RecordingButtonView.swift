//
//  RecordingButtonView.swift
//  VoiceCalc
//
//  Created by Вячеслав Пуханов on 15.12.2019.
//  Copyright © 2019 Вячеслав Пуханов. All rights reserved.
//

import SwiftUI

struct RecordingButtonView: View {
    var body: some View {
        Button(action: {
            
        }) {
            Image(systemName: "mic")
                .font(.largeTitle)
                .padding()
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .background(Color.red)
        .cornerRadius(10.0)
    }
}

struct RecordingButtonView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingButtonView()
    }
}
