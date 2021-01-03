//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Chien on 2017/6/21.
//  Copyright © 2017年 Chien. All rights reserved.
//

import Foundation

enum typeOfButton {
    case isConstant(Double)
    case isOperator((Double, Double) -> Double)
    case isMathematics((Double) -> Double)
    case isEqual
    case isAC
    case isNumber
}

let eachButtonStyle: [String: typeOfButton] = ["π": .isConstant(Double.pi),
                                               "√": .isMathematics(sqrt),
                                               "cos": .isMathematics(cos),
                                               "±": .isMathematics({-$0}),
                                               "+": .isOperator({$0 + $1}),
                                               "−": .isOperator({$0 - $1}),
                                               "×": .isOperator({$0 * $1}),
                                               "÷": .isOperator({$0 / $1}),
                                               "=": .isEqual,
                                               "AC": .isAC]

struct countOperation {
    let firstNum: Double
    let operaFunc: (Double, Double) -> Double

    func doOpreation(secondNum: Double) -> Double {
        return operaFunc(firstNum, secondNum)
    }
}

class CalculatorModel {

    var thisExpression: countOperation?
    var resultIsPending: Bool? = nil

    var buttonLabel: String = "", description: String = "", result: String = ""
    var valueOfResult: Double {
        get {
            return Double(self.result) ?? 0.0
        }

        set {
//            self.result = String(format: "%g", newValue) // -> π 的精準度會被吃掉
            self.result = newValue.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(newValue))" : "\(newValue)"
        }
    }

    var isNewToken: Bool = true
    var isNewExpression: Bool = true

    func setUp(buttonLabel: String) {
        self.buttonLabel = buttonLabel // description 與 result 將一直存在，直到 calModel 消失為止
    }

    func getFinalBack() -> (String, String) {
        let finalStr = self.resultIsPending == nil ? "" : self.resultIsPending! ? "..." : "="
        self.resultIsPending = nil
        return ("\(self.description)\(finalStr)", self.result)
    }

    func computeValue() {
        if self.thisExpression == nil { return }
        self.valueOfResult = (self.thisExpression?.doOpreation(secondNum: self.valueOfResult))!
        self.thisExpression = nil
    }

    func doCalculator() {

        switch eachButtonStyle[self.buttonLabel] ?? .isNumber {
        case .isAC :
            self.thisExpression = nil
            self.resultIsPending = nil
            self.isNewToken = true
            self.isNewExpression = true
            self.valueOfResult = 0.0
            self.description = "0"

        case .isEqual :
            self.computeValue() // 去算值
            self.isNewToken = true
            self.isNewExpression = true
            self.resultIsPending = false

        case .isOperator(let function) :
            let lastChar = self.description.characters.count > 0 ?
                                String(self.description.characters.dropFirst(self.description.characters.count - 1)) : ""

            if lastChar == "+" || lastChar == "−" || lastChar == "×" || lastChar == "÷" {
                self.resultIsPending = true // 仍然正在累加中
                return
            }

            if self.buttonLabel == "×" || self.buttonLabel == "÷" {
                self.description = "(\(self.description))\(self.buttonLabel)"
            } else { self.description += self.buttonLabel }

            self.isNewExpression = false // 因為又按了運算元，所以算式繼續進行

            if self.thisExpression != nil && !self.isNewToken { self.computeValue() } //  去算值，已經有算式準備運算 && 代表上一個是輸入Number
            self.thisExpression = countOperation(firstNum: self.valueOfResult, operaFunc: function)
            self.isNewToken = true
            self.resultIsPending = true

        case .isMathematics(let function) :
            if self.isNewExpression { // 1 + 9 = √ 顯示 √10
                self.description = "\(self.buttonLabel)(\(self.description))"
                self.resultIsPending = false
            } else { // 1 + 9 √ 顯示 1 + √9
                     // 1 + 4 * π √ 要顯示 1 + 4 * √π (特殊例子)
                self.description = self.result == "\(Double.pi)" ? String(self.description.characters.dropLast(1)) :
                                                                    String(self.description.characters.dropLast(self.result.characters.count))
                self.description += self.result == "\(Double.pi)" ? "\(self.buttonLabel)(π)" : "\(self.buttonLabel)(\(self.result))"
            }

            self.valueOfResult = function(self.valueOfResult)
            self.isNewToken = true

        case .isConstant(let value) :
            if self.isNewExpression {
                self.description = self.buttonLabel
                self.isNewExpression = false
            } else { self.description += self.buttonLabel }

            self.valueOfResult = value
            self.isNewToken = false // 與輸入Number一樣的意思

        case .isNumber:
            if !self.isNewToken && self.buttonLabel == "." && self.result.contains(".") { return } // 重複點擊 . 會沒反應

            if self.isNewExpression {
                self.description = self.buttonLabel == "." ? "0." : self.buttonLabel // 重新開始時點擊 . 會自動帶入 0.
                self.isNewExpression = false
            } else { self.description += self.buttonLabel == "." && self.isNewToken ? "0." : self.buttonLabel } // 累加新數字時點 . 帶 0.

            if self.isNewToken {
                self.result = self.buttonLabel == "." ? "0." : self.buttonLabel // 一開始點擊 . 時會自動帶入 0.
                self.isNewToken = false
            } else { self.result += self.buttonLabel }
        }
    }
}
