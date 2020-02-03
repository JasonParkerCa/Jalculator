//
//  ContentView.swift
//  Jalculator
//
//  Created by Jason Parker on 2019-08-25.
//  Copyright © 2019 Jason Parker. All rights reserved.
//

import SwiftUI

struct ButtonTextView: View {
    var title: String
    var isBold: Bool
    var color: Color
    var body: some View {
        if isBold {
            return Text(title).font(.largeTitle).foregroundColor(color).bold()
        } else {
            return Text(title).font(.largeTitle).foregroundColor(color)
        }
    }
}

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
    let buttonTapSoundEffectPlayer = ButtonTapSoundEffect()
    
    func pressClear() {
        appState = .Clear
    }
    
    func pressNumber(number: String) {
        switch appState {
        case .Clear:
            clearButtonTitle = "C"
            displayString = number
        case .Number, .DecimalPoint, .Operation:
            displayString += number
        case .Equal:
            appState = isDecimalState(expression: displayString) ? .Number(true) : .Number(false)
            displayString += number
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
            print(tempResult)
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
                HStack {
                    Spacer()
                    Button(action: {
                        self.buttonTapSoundEffectPlayer.play()
                        self.pressDelete()
                    }) {
                        ButtonTextView(title: "D", isBold: true, color: Color(UIColor.systemBackground))
                    }
                    .frame(width: 80, height: 80)
                    .background(Color(UIColor.systemGray))
                    .cornerRadius(100)
                    Spacer()
                    Button(action: {
                        self.buttonTapSoundEffectPlayer.play()
                        self.pressToggle()
                    }) {
                        ButtonTextView(title: "+/-", isBold: true, color: Color(UIColor.systemBackground))
                    }
                    .frame(width: 80, height: 80)
                    .background(Color(UIColor.systemGray))
                    .cornerRadius(100)
                    Spacer()
                    Button(action: {
                        self.buttonTapSoundEffectPlayer.play()
                        self.pressRoot()
                    }) {
                        ButtonTextView(title: "√a", isBold: true, color: Color(UIColor.systemBackground))
                    }
                    .frame(width: 80, height: 80)
                    .background(Color(UIColor.systemGray))
                    .cornerRadius(100)
                    Spacer()
                    Button(action: {
                        self.buttonTapSoundEffectPlayer.play()
                        self.pressClear()
                    }) {
                        ButtonTextView(title: clearButtonTitle, isBold: true, color: Color(UIColor.systemBackground))
                    }
                    .frame(width: 80, height: 80)
                    .background(Color(UIColor.systemGray))
                    .cornerRadius(100)
                    Spacer()
                }.padding(.bottom, 20)
                HStack {
                    Spacer()
                    ForEach(["7", "8", "9"], id: \.self) { title in
                        Group {
                            Button(action: {
                                self.buttonTapSoundEffectPlayer.play()
                                self.pressNumber(number: title)
                            }) {
                                ButtonTextView(title: title, isBold: true, color: Color(UIColor.systemBackground))
                            }
                            .frame(width: 80, height: 80)
                            .background(Color(UIColor.label))
                            .cornerRadius(100)
                            Spacer()
                        }
                    }
                    Button(action: {
                        self.buttonTapSoundEffectPlayer.play()
                        self.pressOperation(operation: .divide)
                    }) {
                        ButtonTextView(title: Operation.divide.rawValue, isBold: true, color: Color(UIColor.systemBackground))
                    }
                    .frame(width: 80, height: 80)
                    .background(Color(UIColor.systemGray))
                    .cornerRadius(100)
                    Spacer()
                }.padding(.bottom, 20)
                HStack {
                    Spacer()
                    ForEach(["4", "5", "6"], id: \.self) { title in
                        Group {
                            Button(action: {
                                self.buttonTapSoundEffectPlayer.play()
                                self.pressNumber(number: title)
                            }) {
                                ButtonTextView(title: title, isBold: true, color: Color(UIColor.systemBackground))
                            }
                            .frame(width: 80, height: 80)
                            .background(Color(UIColor.label))
                            .cornerRadius(100)
                            Spacer()
                        }
                    }
                    Button(action: {
                        self.buttonTapSoundEffectPlayer.play()
                        self.pressOperation(operation: .multiply)
                    }) {
                        ButtonTextView(title: Operation.multiply.rawValue, isBold: true, color: Color(UIColor.systemBackground))
                    }
                    .frame(width: 80, height: 80)
                    .background(Color(UIColor.systemGray))
                    .cornerRadius(100)
                    Spacer()
                }.padding(.bottom, 20)
                HStack {
                    Spacer()
                    ForEach(["1", "2", "3"], id: \.self) { title in
                        Group {
                            Button(action: {
                                self.buttonTapSoundEffectPlayer.play()
                                self.pressNumber(number: title)
                            }) {
                                ButtonTextView(title: title, isBold: true, color: Color(UIColor.systemBackground))
                            }
                            .frame(width: 80, height: 80)
                            .background(Color(UIColor.label))
                            .cornerRadius(100)
                            Spacer()
                        }
                    }
                    Button(action: {
                        self.buttonTapSoundEffectPlayer.play()
                        self.pressOperation(operation: .add)
                    }) {
                        ButtonTextView(title: Operation.add.rawValue, isBold: true, color: Color(UIColor.systemBackground))
                    }
                    .frame(width: 80, height: 80)
                    .background(Color(UIColor.systemGray))
                    .cornerRadius(100)
                    Spacer()
                }.padding(.bottom, 20)
                HStack {
                    Spacer()
                    Button(action: {
                        self.buttonTapSoundEffectPlayer.play()
                        self.pressDecimalPoint()
                    }) {
                        ButtonTextView(title: ".", isBold: true, color: Color(UIColor.systemBackground))
                    }
                    .frame(width: 80, height: 80)
                    .background(Color(UIColor.systemGray))
                    .cornerRadius(100)
                    Spacer()
                    Button(action: {
                        self.buttonTapSoundEffectPlayer.play()
                        self.pressNumber(number: "0")
                    }) {
                        ButtonTextView(title: "0", isBold: true, color: Color(UIColor.systemBackground))
                    }
                    .frame(width: 80, height: 80)
                    .background(Color(UIColor.label))
                    .cornerRadius(100)
                    Spacer()
                    Button(action: {
                        self.buttonTapSoundEffectPlayer.play()
                        self.pressEqual()
                    }) {
                        ButtonTextView(title: "=", isBold: true, color: Color(UIColor.systemBackground))
                    }
                    .frame(width: 80, height: 80)
                    .background(Color(UIColor.systemGray))
                    .cornerRadius(100)
                    Spacer()
                    Button(action: {
                        self.buttonTapSoundEffectPlayer.play()
                        self.pressOperation(operation: .minus)
                    }) {
                        ButtonTextView(title: Operation.minus.rawValue, isBold: true, color: Color(UIColor.systemBackground))
                    }
                    .frame(width: 80, height: 80)
                    .background(Color(UIColor.systemGray))
                    .cornerRadius(100)
                    Spacer()
                }.padding(.bottom, 20)
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
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
