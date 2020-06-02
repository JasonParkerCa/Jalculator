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
    
    func isNegative(string: String) -> Bool {
        for character in string {
            if "+" == character || "*" == character || "/" == character {
                return false
            }
        }
        if string[string.startIndex] == "-" {
            return true
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
    
    func formatExpression(expression: String) -> String {
        var components = ExpressionString()
        var tempString = ""
        var containedE = false
        for character in expression {
            let cString = String(character)
            if isNumber(string: cString) || cString == "." || cString == "e" || containedE == true {
                if !operationSymbols.contains(cString) {
                    tempString += cString
                }
                if cString == "e" {
                    containedE = true
                } else {
                    containedE = false
                }
            } else if operationSymbols.contains(cString) && containedE == false {
                components.numbers.append(tempString)
                components.operations.append(cString)
                tempString.removeAll()
            }
        }
        components.numbers.append(tempString)
        for (index, number) in components.numbers.enumerated() {
            if isDecimalState(expression: number) {
                components.numbers[index] = "(\(number))"
            } else {
                components.numbers[index] = "(\(number).0)"
            }
        }
        var newExpression = ""
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
        if newRsult.last! == "0" && newRsult[newRsult.index(before: newRsult.lastIndex(of: "0")!)] == "." {
            newRsult.removeLast()
            newRsult.removeLast()
        }
        return newRsult
    }
    
}
