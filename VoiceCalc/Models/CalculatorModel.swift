//
//  CalculatorModel.swift
//  VoiceCalc
//
//  Created by Вячеслав Пуханов on 15.12.2019.
//  Copyright © 2019 Вячеслав Пуханов. All rights reserved.
//

import Combine
import SwiftUI

class CalculatorElement {
    let id: String = UUID().uuidString
    var representation: String
    
    init(representation: String) {
        self.representation = representation
    }
}

class NumberCalculatorElement: CalculatorElement {
    var numberRepresentation: Double
    var isResult: Bool
    
    init(representation: String, isResult: Bool) {
        self.isResult = isResult
        guard let numberRepresentation = Double(representation) else {
            fatalError("The string \"\(representation)\" does not have a number representation")
        }
        self.numberRepresentation = numberRepresentation
        super.init(representation: representation)
    }
}

enum OperationRepresentation {
    case add
    case subtract
    case multiply
    case divide
    
    static func representation(from str: String) -> OperationRepresentation {
        return .add
    }
}

class OperationCalculatorElement: CalculatorElement {
    var operationRepresentation: OperationRepresentation
    
    override init(representation: String) {
        self.operationRepresentation = OperationRepresentation.representation(from: representation)
        super.init(representation: representation)
    }
}

class CalculatorModel: ObservableObject {
    @Published var elements: [CalculatorElement]
    
    init(elements: [CalculatorElement]) {
        self.elements = elements
    }
    
    #if DEBUG
    static let debugModel = CalculatorModel(elements: [
        NumberCalculatorElement(representation: "3", isResult: true),
        NumberCalculatorElement(representation: "1", isResult: false),
        OperationCalculatorElement(representation: "-"),
        NumberCalculatorElement(representation: "4", isResult: true),
        NumberCalculatorElement(representation: "2", isResult: false),
        OperationCalculatorElement(representation: "+"),
        NumberCalculatorElement(representation: "2", isResult: false)
    ])
    #endif
}
