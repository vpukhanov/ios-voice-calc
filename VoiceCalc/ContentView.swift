//
//  ContentView.swift
//  VoiceCalc
//
//  Created by Вячеслав Пуханов on 15.12.2019.
//  Copyright © 2019 Вячеслав Пуханов. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var model: CalculatorModel
    
    var body: some View {
        MainScreen(model: model)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: CalculatorModel.debugModel)
    }
}
