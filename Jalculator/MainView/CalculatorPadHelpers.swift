//
//  CalculatorPadFunctions.swift
//  Jalculator
//
//  Created by Jason Parker on 2019-09-02.
//  Copyright © 2019 Jason Parker. All rights reserved.
//

import SwiftUI

extension MainView {
    
    func isInt(number: Double) -> Bool {
        return (number == floor(number))
    }
    
    func isNumber(string: String) -> Bool {
        return Int(string) != nil ? true : false
    }
    
    func isLastNumberNegative(expression: String) -> Bool {
        if let first_character = expression.first {
            if first_character == "-" {
                return true
            }
        }
        let reversedExpression = String(expression.reversed())
        if let lastNumber_Range = reversedExpression.range(of: "([0-9]|\\.|\\(|\\)|\\-)+((?=\\+|\\-|\\\(Operation.multiply.rawValue)|\\\(Operation.divide.rawValue)))?", options: .regularExpression, range: nil, locale: nil) {
            if ifOperationIncluded(expression: String(reversedExpression[lastNumber_Range])) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func isDecimalState(expression: String) -> Bool {
        for character in expression.reversed() {
            if character == "." {
                return true
            } else if operationSymbols.contains(String(character)) {
                return false
            }
        }
        return false
    }
    
    func ifOperationIncluded(expression: String) -> Bool {
        for character in expression {
            if operationSymbols.contains(String(character)) {
                return true
            }
        }
        return false
    }
    
    func numberOfOperations(expression: String) -> Int {
        var number = 0
        for character in expression {
            if operationSymbols.contains(String(character)) {
                number += 1
            }
        }
        return number
    }
    
    func lastExpression(expression: String) -> String {
        var lastExpression = ""
        for character in expression.reversed() {
            lastExpression += String(character)
            if ["+", "-", "*", "/"].contains(character) {
                return String(lastExpression.reversed())
            }
        }
        return String(lastExpression.reversed())
    }
    
    func positiveLastNumber(expression: String, isEqualMode: Bool) -> String {
        if isEqualMode == true {
            return expression.replacingOccurrences(of: "-", with: "")
        }
        let newExpression = String(expression.reversed())
        if let lastNumber_Range = newExpression.range(of: "\\)([0-9]|\\-|\\.)+\\(", options: .regularExpression, range: nil, locale: nil) {
            var newNumber = String(newExpression[lastNumber_Range])
            newNumber.removeFirst()
            newNumber.removeLast()
            newNumber.removeLast()
            return String(newExpression.replacingCharacters(in: lastNumber_Range, with: newNumber).reversed())
        } else {
            return expression
        }
    }
    
    func negativeLastNumber(expression: String) -> String {
        let newExpression = String(expression.reversed())
        if let lastNumber_Range = newExpression.range(of: "([0-9]|\\.|\\(|\\)|\\-)+((?=\\+|\\-|\\\(Operation.multiply.rawValue)|\\\(Operation.divide.rawValue)))?", options: .regularExpression, range: nil, locale: nil) {
            var newNumber = String(newExpression[lastNumber_Range])
            newNumber = ")\(newNumber)-("
            return String(newExpression.replacingCharacters(in: lastNumber_Range, with: newNumber).reversed())
        } else {
            return expression
        }
    }
    
    func formatExpression(expression: String) -> String {
        var components = ExpressionString()
        var tempString = expression
        while true {
            if let number_Range = tempString.range(of: "([0-9]|\\.)+|(?<=\\()([0-9]|\\.|\\-)+(?=\\))", options: .regularExpression, range: nil, locale: nil) {
                components.numbers.append(String(tempString[number_Range]))
                tempString = tempString.replacingCharacters(in: number_Range, with: "")
            } else {
                break
            }
        }
        for character in tempString {
            let character_String = String(character)
            if operationSymbols.contains(character_String) {
                components.operations.append(character_String)
            }
        }
        for (index, number) in components.numbers.enumerated() {
            if isDecimalState(expression: number) {
                components.numbers[index] = "(\(number))"
            } else {
                components.numbers[index] = "(\(number).0)"
            }
        }
        var newExpression = String()
        for (index, number) in components.numbers.enumerated() {
            newExpression += number
            if index < components.operations.count {
                newExpression += components.operations[index]
            }
        }
        newExpression = newExpression.replacingOccurrences(of: Operation.multiply.rawValue, with: "*")
        newExpression = newExpression.replacingOccurrences(of: Operation.divide.rawValue, with: "/")
        return newExpression
    }
    
    func formatResult(result: Decimal) -> String {
        var temp = result
        var tempResult: Decimal = 0
        NSDecimalRound(&tempResult, &temp, settings.numberOfDecimalSpacesRoundTo, .bankers)
        var newRsult = "\(tempResult)"
        if tempResult == 0 {
            return "0"
        } else {
            if newRsult.last! == "0" && newRsult[newRsult.index(before: newRsult.lastIndex(of: "0")!)] == "." {
                newRsult.removeLast()
                newRsult.removeLast()
            }
            return newRsult
        }
    }
    
}
