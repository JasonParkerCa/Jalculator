//
//  Expression.swift
//  Jalculator
//
//  Created by Jason Parker on 2020-05-31.
//  Copyright © 2020 Jason Parker. All rights reserved.
//

import Foundation

class Expression {
    
    var expressionString: String
    
    init(expressionString: String) {
        self.expressionString = expressionString
    }
    
    func calculate() -> Decimal? {
        process(mode: "*/")
        process(mode: "+-")
        expressionString.remove(at: expressionString.startIndex)
        expressionString.remove(at: expressionString.index(before: expressionString.endIndex))
        return Decimal(string: expressionString)
    }
    
    func process(mode: String) {
        let regex_subExpression = mode == "*/" ? "\\(([0-9]|\\.|\\-)+\\)[\\*|\\/]\\(([0-9]|\\.|\\-)+\\)" : "\\(([0-9]|\\.|\\-)+\\)[\\+|\\-]\\(([0-9]|\\.|\\-)+\\)"
        let regex_operation = "(?<=\\)).{1}(?=\\()"
        let regex_number = "(?<=\\()([0-9]|\\.|\\-)+(?=\\))"
        while true {
            if let subExpressionRange = expressionString.range(of: regex_subExpression, options: .regularExpression, range: nil, locale: nil) {
                let subExpression = String(expressionString[subExpressionRange])
                let numbers = matches(for: regex_number, in: subExpression)
                let operation = subExpression[subExpression.range(of: regex_operation, options: .regularExpression, range: nil, locale: nil)!]
                var result: Decimal = 0
                if operation == "*" {
                    result = Decimal(string: numbers[0])! * Decimal(string: numbers[1])!
                } else if operation == "/" {
                    result = Decimal(string: numbers[0])! / Decimal(string: numbers[1])!
                } else if operation == "+" {
                    result = Decimal(string: numbers[0])! + Decimal(string: numbers[1])!
                } else {
                    result = Decimal(string: numbers[0])! - Decimal(string: numbers[1])!
                }
                expressionString.replaceSubrange(subExpressionRange, with: "(\(result))")
            } else {
                return
            }
        }
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
}
