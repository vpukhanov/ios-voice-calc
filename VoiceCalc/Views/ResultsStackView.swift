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
        VStack(alignment: .leading, spacing: 16) {
            ForEach(model.elements, id: \.id) { element in
                ResultsStackRow(element: element)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ResultsStackView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsStackView(model: CalculatorModel.debugModel)
    }
}

struct ResultsStackRow: View {
    let element: CalculatorElement
    
    var body: some View {
        VStack(spacing: 16) {
            Text((equalsNeeded() ? "= " : "") + element.representation)
                .font(.system(size: 42))
                .fontWeight(.light)
                .foregroundColor(highlightColor())
        }
    }
    
    func highlightColor() -> Color? {
        if let numberElement = element as? NumberCalculatorElement, numberElement.isResult {
            return .green
        } else if element is ErrorCalculatorElement {
            return .red
        }
        return nil
    }
    
    func equalsNeeded() -> Bool {
        if let numberElement = element as? NumberCalculatorElement {
            return numberElement.isResult
        }
        return false
    }
}
