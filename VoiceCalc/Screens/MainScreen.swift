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
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Main results view
            ScrollView {
                ResultsStackView(model: model)
                    .padding(.horizontal)
            }
            
            // Recording button
            VStack {
                Spacer()
                RecordingButtonView()
            }
            .padding(.horizontal)
        }
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen(model: CalculatorModel.debugModel)
    }
}
