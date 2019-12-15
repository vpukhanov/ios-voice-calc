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
    var numberRepresentation: Int
    var isResult: Bool
    
    init(representation: String, isResult: Bool) {
        self.isResult = isResult
        guard let numberRepresentation = Int(representation) else {
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
    
    static let addParts = ["прибав", "добав", "плюс", "+"]
    static let subtractParts = ["вычест", "вычит", "минус", "−", "-"]
    static let multiplyParts = ["множ", "×"]
    static let divideParts = ["дели", "делен", "/", "÷"]
    
    static func representation(from str: String) -> OperationRepresentation? {
        if OperationRepresentation.addParts.contains(where: str.contains) {
            return .add
        } else if OperationRepresentation.subtractParts.contains(where: str.contains) {
            return .subtract
        } else if OperationRepresentation.multiplyParts.contains(where: str.contains) {
            return .multiply
        } else if OperationRepresentation.divideParts.contains(where: str.contains) {
            return .divide
        } else {
            return nil
        }
    }
}

class OperationCalculatorElement: CalculatorElement {
    var operationRepresentation: OperationRepresentation
    
    override init(representation: String) {
        guard let operationRepresentation = OperationRepresentation.representation(from: representation) else {
            fatalError("The string \"\(representation)\" does not have an operator representation")
        }
        self.operationRepresentation = operationRepresentation
        super.init(representation: representation)
    }
}

class CalculatorModel: ObservableObject {
    @Published var elements: [CalculatorElement]
    
    init(elements: [CalculatorElement]) {
        self.elements = elements
    }
    
    func process(utterance: [String]) -> Void {
        utterance.forEach { part in
            addPart(part, lastElement: elements.first)
        }
    }
    
    private func addPart(_ part: String, lastElement: CalculatorElement?) {
        if OperationRepresentation.representation(from: part) != nil {
            // This is an operator
            let newElement = OperationCalculatorElement(representation: part)
            if lastElement != nil && lastElement is OperationCalculatorElement {
                // Replace the old operator with the new one
                elements.remove(at: 0)
            }
            // Insert the new operator
            elements.insert(newElement, at: 0)
        } else if Int(part) != nil {
            // This is a number
            var newElement: NumberCalculatorElement
            if lastElement != nil && lastElement is NumberCalculatorElement && !(lastElement as! NumberCalculatorElement).isResult {
                // There was a non-result number before it, append it instead
                newElement = NumberCalculatorElement(representation: lastElement!.representation + part, isResult: false)
                elements.remove(at: 0)
            } else {
                // There was nothing before it, a result number or an operator
                newElement = NumberCalculatorElement(representation: part, isResult: false)
            }
            elements.insert(newElement, at: 0)
        } else {
            // This token should be ignored
        }
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
