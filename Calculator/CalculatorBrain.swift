//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by zklgame on 15/10/1.
//  Copyright © 2015年 zklgame. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Operation: CustomStringConvertible
    {
        case UnaryOperation(String, Double->Double)
        case BinaryOperation(String, (Double, Double)->Double)
        
        var description: String {
            get {
                switch self {
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
        
        var priority: Int {
            get {
                switch self {
                case .UnaryOperation(_, _):
                    return 3
                case .BinaryOperation(let symbol, _):
                    switch symbol {
                        case "+": return 1
                        case "−": return 1
                        case "×": return 2
                        case "÷": return 2
                        default: return -1
                    }
                }
            }
        }
    }
    
    private var operandStack = [Double]()

    private var operationStack = [Operation]()
    
    private var knownOps = [String: Operation]()
    
    private var isLastEnterAOperation = false
    
    private var hasJustGetResult = false
    
    init() {
        func learnOp(operation: Operation) {
            knownOps[operation.description] = operation
        }
        learnOp(Operation.BinaryOperation("+", +))
        learnOp(Operation.BinaryOperation("−"){$1 - $0})
        learnOp(Operation.BinaryOperation("×", *))
        learnOp(Operation.BinaryOperation("÷"){$1 / $0})
        learnOp(Operation.UnaryOperation("√", sqrt))
    }
    
    private func evaluate(operandStack: [Double], operationStack: [Operation]) -> (result: Double?, remainingOperandStack: [Double], remainingOperationStack: [Operation]) {
        if !operandStack.isEmpty {
            var remainingOperandStack = operandStack
            let operand1 = remainingOperandStack.removeLast()
            
            if operationStack.isEmpty {
                return (operand1, remainingOperandStack, operationStack)
            }
            
            var remainingOperationStack = operationStack
            let op1 = remainingOperationStack.removeLast()
            
            if remainingOperationStack.isEmpty {
                switch op1 {
                case .UnaryOperation(_, let operation):
                    return (operation(operand1), remainingOperandStack, remainingOperationStack)
                case .BinaryOperation(_, let operation):
                    if remainingOperandStack.count >= 1 {
                        return (operation(operand1, remainingOperandStack.removeLast()), remainingOperandStack, remainingOperationStack)
                    } else {
                        return (operand1, remainingOperandStack, operationStack)
                    }
                }
            } else {
                let op2 = remainingOperationStack.removeLast()
                if op2.priority >= op1.priority {
                    remainingOperationStack.append(op1)
                    switch op2 {
                    case .UnaryOperation(_, let operation):
                        return (operation(operand1), remainingOperandStack, remainingOperationStack)
                    case .BinaryOperation(_, let operation):
                        if remainingOperandStack.count >= 1 {
                            return (operation(operand1, remainingOperandStack.removeLast()), remainingOperandStack, remainingOperationStack)
                        } else {
                            return (operand1, remainingOperandStack, remainingOperationStack)
                        }
                    }
                } else {
                    return (operand1, remainingOperandStack, operationStack)
                }
            }
            
        }
        
        return (nil, operandStack, operationStack)
    }
    
    func evaluate() -> Double? {
        var (result, remainingOperandStack, remainingOperationStack) = evaluate(operandStack, operationStack: operationStack)
        
        if (result != nil) {
            operandStack = remainingOperandStack
            operandStack.append(result!)
            operationStack = remainingOperationStack
        }
        
        print("\(operandStack) and \(operationStack) = \(result) with \(remainingOperandStack) and \(remainingOperationStack) left over")
        
        if (remainingOperationStack.count >= 2) {
            let op1 = remainingOperationStack.removeLast()
            let op2 = remainingOperationStack.removeLast()
            if op2.priority >= op1.priority {
                result = evaluate()
            }
        }
        
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        if hasJustGetResult {
            hasJustGetResult = false
            clear()
        }
        isLastEnterAOperation = false
        operandStack.append(operand)
        return operand
    }
    
    func performOperation(symbol: String) -> Double? {
        hasJustGetResult = false
        
        if let operation = knownOps[symbol] {
            if operation.priority < 3 && isLastEnterAOperation && operationStack.count > 0 {
                operationStack.removeLast()
            }
            operationStack.append(operation)
            isLastEnterAOperation = true
        }
        return evaluate()
    }
    
    func getResult() -> Double? {
        if isLastEnterAOperation && operationStack.count > 0 {
            operationStack.removeLast()
        }
        let result = performOperation("+")
        operationStack.removeLast()
        hasJustGetResult = true
        
        print("\(operandStack) and \(operationStack)")

        return result
    }
    
    func clear() {
        operandStack.removeAll(keepCapacity: false)
        operationStack.removeAll(keepCapacity: false)
        isLastEnterAOperation = false
    }
    
}