//
//  ResultsStackView.swift
//  VoiceCalc
//
//  Created by Вячеслав Пуханов on 15.12.2019.
//  Copyright © 2019 Вячеслав Пуханов. All rights reserved.
//

import SwiftUI

struct ResultsStackView: View {
    @ObservedObject var model: CalculatorModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(model.elements, id: \.id) { element in
                self.rowView(for: element)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func rowView(for element: CalculatorElement) -> some View {
        let isResult = element is NumberCalculatorElement && (element as! NumberCalculatorElement).isResult
        return ResultsStackRow(
            text: element.representation,
            highlightColor: isResult ? Color.green : nil
        )
    }
}

struct ResultsStackView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsStackView(model: CalculatorModel.debugModel)
    }
}

struct ResultsStackRow: View {
    let text: String
    
    var highlightColor: Color? = nil
    
    var body: some View {
        Text(text)
            .font(.largeTitle)
            .foregroundColor(highlightColor)
    }
}
