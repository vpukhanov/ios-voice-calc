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

enum CalculatorErrors: Error {
    case divideByZero
}

class ErrorCalculatorElement: CalculatorElement {
    var error: Error
    
    init(error: Error) {
        self.error = error
        super.init(representation: "💣 Ошибка!")
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
    
    func execute(_ op1: Int, _ op2: Int) throws -> Int {
        switch operationRepresentation {
        case .add:
            return op1 + op2
        case .subtract:
            return op1 - op2
        case .multiply:
            return op1 * op2
        case .divide:
            if op2 == 0 {
                throw CalculatorErrors.divideByZero
            }
            return op1 / op2
        }
    }
}

class CalculatorModel: ObservableObject {
    @Published var elements: [CalculatorElement]
    var isResetable: Bool {
        elements.count > 1
    }
    
    private lazy var russianFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.numberStyle = .spellOut
        return formatter
    }()
    
    init(elements: [CalculatorElement]) {
        self.elements = elements
    }
    
    func process(utterance: [String]) -> Void {
        do {
            try utterance.forEach { part in
                try addPart(part)
            }
            try processPreviousOperation()
        } catch {
            elements.insert(ErrorCalculatorElement(error: error), at: 0)
        }
    }
    
    func reset() {
        elements = [
            NumberCalculatorElement(representation: "0", isResult: true)
        ]
    }
    
    private func addPart(_ part: String) throws {
        let part = part.lowercased()
        if OperationRepresentation.representation(from: part) != nil {
            try processPreviousOperation()
            addOperator(part, lastElement: elements.first)
        } else if Int(part) != nil {
            addNumber(part, lastElement: elements.first)
        } else {
            // This token should be ignored
            // There is still a chance that this is a number however 🤡
            // because SpeechKit might have recognized "50" as "пятьдесят" 🤡🤡
            // or even (in some cases) "писят" 🤡🤡🤡
            // So we should try to convert this string to a number
            if let number = speltOutStringToNumber(part) {
                try addPart(String(number))
            }
        }
    }
    
    private func addOperator(_ part: String, lastElement: CalculatorElement?) {
        let newElement = OperationCalculatorElement(representation: part)
        if lastElement != nil && lastElement is OperationCalculatorElement {
            // Replace the old operator with the new one
            elements.remove(at: 0)
        }
        // Insert the new operator
        elements.insert(newElement, at: 0)
    }
    
    private func addNumber(_ part: String, lastElement: CalculatorElement?) {
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
    }
    
    private func processPreviousOperation() throws {
        if elements.count < 3 { return }
        
        guard let secondOperand = elements[0] as? NumberCalculatorElement else { return }
        guard let operation = elements[1] as? OperationCalculatorElement else { return }
        guard let firstOperand = elements[2] as? NumberCalculatorElement else { return }
        
        let result = try operation.execute(firstOperand.numberRepresentation, secondOperand.numberRepresentation)
        let resultElement = NumberCalculatorElement(representation: String(result), isResult: true)
        
        elements.insert(resultElement, at: 0)
    }
    
    private func speltOutStringToNumber(_ str: String) -> Int? {
        switch str {
        // Praise the amazing Apple Russian language model 🙏
        case "писят":
            return 50
        default:
            return russianFormatter.number(from: str)?.intValue
        }
    }
    
    static let debugModel = CalculatorModel(elements: [
        NumberCalculatorElement(representation: "3", isResult: true),
        NumberCalculatorElement(representation: "1", isResult: false),
        OperationCalculatorElement(representation: "-"),
        NumberCalculatorElement(representation: "4", isResult: true),
        NumberCalculatorElement(representation: "2", isResult: false),
        OperationCalculatorElement(representation: "+"),
        NumberCalculatorElement(representation: "2", isResult: false)
    ])
}
