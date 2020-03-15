//
//  ContentView.swift
//  Jalculator
//
//  Created by Jason Parker on 2019-08-25.
//  Copyright © 2019 Jason Parker. All rights reserved.
//

import SwiftUI

let buttonTapSoundEffectPlayer = ButtonTapSoundEffect()
let buttonSize = UIScreen.main.bounds.width > 414 ? 100 : UIScreen.main.bounds.width * 0.75 / 4

struct MainView: View {
    
    enum AppState {
        case Number(_ Decimal: Bool)
        case DecimalPoint
        case Operation
        case Equal(_ Decimal: Bool)
        case Error
        case Clear
    }
    
    enum Operation: String {
        case add = "+"
        case minus = "-"
        case multiply = "×"
        case divide = "÷"
    }
    
    struct ExpressionString {
        var numbers = [String]()
        var operations = [String]()
    }
    
    struct ButtonAttributes {
        var id = UUID()
        var text: String
        var textColor: UIColor
        var backgroundColor: UIColor
        var action: () -> ()
    }
    
    let operationSymbols = ["+", "-", "×", "÷"]
    
    @State var clearButtonTitle = "AC"
    @State var displayString: String = " " {
        willSet {
            if newValue.count > 0 {
                let lastElement = String(newValue.last!)
                if lastElement == "." {
                    appState = .DecimalPoint
                } else if operationSymbols.contains(lastElement) {
                    appState = .Operation
                } else if isNumber(string: lastElement) {
                    switch appState {
                    case .Equal:
                        return
                    default:
                        appState = isDecimalState(expression: newValue) ? .Number(true) : .Number(false)
                    }
                }
            }
        }
    }
    @State var backupDisplayString = ""
    @State var lastExpression = ""
    @State var isSettingsViewPresented = false
    @State var isInfoViewPresented = false
    @State var appState = AppState.Clear {
        willSet {
            switch newValue {
            case .Clear:
                displayString = " "
                backupDisplayString.removeAll()
                clearButtonTitle = "AC"
            case .Error:
                backupDisplayString = displayString
                displayString = "Error"
            default:
                return
            }
        }
    }
    
    @EnvironmentObject var settings: Settings
    
    func pressClear() {
        appState = .Clear
    }
    
    func pressNumber(number: Int) {
        let numberString = String(number)
        switch appState {
        case .Clear:
            clearButtonTitle = "C"
            displayString = numberString
        case .Number, .DecimalPoint, .Operation:
            displayString += numberString
        case .Equal:
            appState = isDecimalState(expression: displayString) ? .Number(true) : .Number(false)
            displayString += numberString
        default:
            return
        }
    }
    
    func pressDecimalPoint() {
        switch appState {
        case .Number(false), .Equal(false):
            displayString += "."
        default:
            return
        }
    }
    
    func pressOperation(operation: Operation) {
        switch appState {
        case .Number, .Equal:
            displayString += operation.rawValue
        case .Operation:
            displayString.remove(at: displayString.index(before: displayString.endIndex))
            displayString += operation.rawValue
        default:
            return
        }
    }
    
    func pressDelete() {
        switch appState {
        case .Number, .DecimalPoint, .Equal:
            displayString.removeLast()
            appState = displayString == "" ? .Clear : appState
        case .Operation:
            displayString.removeLast()
        case .Error:
            displayString = backupDisplayString
        default:
            return
        }
    }
    
    func pressToggle() {
        switch appState {
        case .Number, .Equal:
            if ifOperationIncluded(expression: displayString) {
                appState = .Error
            } else {
                displayString = "-" + displayString
            }
        default:
            return
        }
    }
    
    func pressRoot() {
        switch appState {
        case .Number, .Equal:
            if ifOperationIncluded(expression: displayString) {
                appState = .Error
            } else {
                let newResult = pow(Double(displayString)!, 0.5)
                displayString = isInt(number: newResult) ? String(Int(newResult)) : String(newResult)
            }
        default:
            return
        }
    }
    
    func pressEqual() {
        switch appState {
        case .Number:
            let expressionString = formatExpression(expression: displayString)
            if numberOfOperations(expression: displayString) == 1 {
                lastExpression = lastExpression(expression: expressionString)
            } else {
                lastExpression = "nil"
            }
            let expression = NSExpression(format: expressionString)
            let tempResult = (expression.expressionValue(with: nil, context: nil) as! NSNumber).doubleValue
            if tempResult.isInfinite || tempResult.isNaN {
                appState = .Error
                return
            }
            displayString = formatResult(result: tempResult)
            appState = isDecimalState(expression: displayString) ? .Equal(true) : .Equal(false)
        case .Equal:
            if lastExpression != "nil" {
                let expressionString = displayString + lastExpression
                let expression = NSExpression(format: expressionString)
                let tempResult = (expression.expressionValue(with: nil, context: nil) as! NSNumber).doubleValue
                displayString = formatResult(result: tempResult)
                appState = isDecimalState(expression: displayString) ? .Equal(true) : .Equal(false)
            }
        default:
            return
        }
    }
    
    var body: some View {
        
        let buttonAttributes = [
            [
                ButtonAttributes(text: "D", textColor: .OperationButtonTextColor, backgroundColor: .OperationButtonBackgroundColor, action: { self.pressDelete() }),
                ButtonAttributes(text: "+/-", textColor: .OperationButtonTextColor, backgroundColor: .OperationButtonBackgroundColor, action: { self.pressToggle() }),
                ButtonAttributes(text: "√x", textColor: .OperationButtonTextColor, backgroundColor: .OperationButtonBackgroundColor, action: { self.pressToggle() }),
                ButtonAttributes(text: clearButtonTitle, textColor: .OperationButtonTextColor, backgroundColor: .OperationButtonBackgroundColor, action: { self.pressClear() }),
            ],
            [
                ButtonAttributes(text: "7", textColor: .systemBackground, backgroundColor: .label, action: { self.pressNumber(number: 7) }),
                ButtonAttributes(text: "8", textColor: .systemBackground, backgroundColor: .label, action: { self.pressNumber(number: 8) }),
                ButtonAttributes(text: "9", textColor: .systemBackground, backgroundColor: .label, action: { self.pressNumber(number: 9) }),
                ButtonAttributes(text: "÷", textColor: .OperationButtonTextColor, backgroundColor: .OperationButtonBackgroundColor, action: { self.pressOperation(operation: .divide) }),
            ],
            [
                ButtonAttributes(text: "4", textColor: .systemBackground, backgroundColor: .label, action: { self.pressNumber(number: 4) }),
                ButtonAttributes(text: "5", textColor: .systemBackground, backgroundColor: .label, action: { self.pressNumber(number: 5) }),
                ButtonAttributes(text: "6", textColor: .systemBackground, backgroundColor: .label, action: { self.pressNumber(number: 6) }),
                ButtonAttributes(text: "×", textColor: .OperationButtonTextColor, backgroundColor: .OperationButtonBackgroundColor, action: { self.pressOperation(operation: .multiply) }),
            ],
            [
                ButtonAttributes(text: "1", textColor: .systemBackground, backgroundColor: .label, action: { self.pressNumber(number: 1) }),
                ButtonAttributes(text: "2", textColor: .systemBackground, backgroundColor: .label, action: { self.pressNumber(number: 2) }),
                ButtonAttributes(text: "3", textColor: .systemBackground, backgroundColor: .label, action: { self.pressNumber(number: 3) }),
                ButtonAttributes(text: "+", textColor: .OperationButtonTextColor, backgroundColor: .OperationButtonBackgroundColor, action: { self.pressOperation(operation: .add) }),
            ],
            [
                ButtonAttributes(text: ".", textColor: .OperationButtonTextColor, backgroundColor: .OperationButtonBackgroundColor, action: { self.pressDecimalPoint() }),
                ButtonAttributes(text: "0", textColor: .systemBackground, backgroundColor: .label, action: { self.pressNumber(number: 0) }),
                ButtonAttributes(text: "=", textColor: .OperationButtonTextColor, backgroundColor: .OperationButtonBackgroundColor, action: { self.pressEqual() }),
                ButtonAttributes(text: "-", textColor: .OperationButtonTextColor, backgroundColor: .OperationButtonBackgroundColor, action: { self.pressOperation(operation: .minus) }),
            ]
        ]
        
        return (
            VStack {
                Spacer()
                Text(displayString)
                    .font(.system(size: 40))
                    .bold()
                    .foregroundColor(Color(UIColor.label))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.leading, 40)
                    .padding(.trailing, 40)
                Spacer()
                VStack {
                    ForEach(buttonAttributes, id: \.first!.id, content: { row in
                        HStack {
                            Group {
                                ForEach(row, id: \.id, content: { column in
                                    Group {
                                        Spacer()
                                        ButtonView(action: column.action, title: column.text, textColor: column.textColor, backgroundColor: column.backgroundColor)
                                    }
                                })
                                Spacer()
                            }
                        }.padding(.bottom, 20)
                    })
                }
                HStack {
                    Spacer()
                    Button(action: {
                        self.isSettingsViewPresented.toggle()
                    }) {
                        Image("settingsIcon")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color(UIColor.label))
                    }
                    .sheet(isPresented: $isSettingsViewPresented, content: {
                        SettingsView().environmentObject(self.settings)
                    })
                    Spacer()
                    Button(action: {
                        self.isInfoViewPresented.toggle()
                    }) {
                        ZStack {
                            Image("questionBackgroundIcon")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color(UIColor.label))
                            Image("questionIcon")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 10, height: 10)
                                .foregroundColor(Color(UIColor.systemBackground))
                        }
                    }
                    .sheet(isPresented: $isInfoViewPresented, content: {
                        InfoView()
                    })
                    Spacer()
                }.padding(.bottom, 20)
            }
        )
    }
}

struct ButtonView: View {
    var action: () -> ()
    var title: String
    var textColor: UIColor
    var backgroundColor: UIColor
    var body: some View {
        return (
            Button(action: {
                self.action()
                buttonTapSoundEffectPlayer.play()
            }, label: {
                Text(title)
                    .font(.title)
                    .bold()
                    .foregroundColor(Color(textColor))
                    .frame(width: buttonSize, height: buttonSize)
                    .mask(Circle())
            })
                .background(Color(backgroundColor))
                .mask(Circle())
        )
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

extension UIColor {
    
    static var OperationButtonBackgroundColor: UIColor {
        return UIColor(named: "OperationButtonBackgroundColor")!
    }
    
    static var OperationButtonTextColor: UIColor {
        return UIColor(named: "OperationButtonTextColor")!
    }
    
}
