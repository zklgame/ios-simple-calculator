//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by zklgame on 15/7/25.
//  Copyright (c) 2015年 Zhu Kaili. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Operation : Printable
    {
        case UnaryOperation(String, Int, Double -> Double)
        case BinaryOparation(String, Int, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .UnaryOperation(let symbol, _, _):
                    return symbol
                case .BinaryOparation(let symbol, _, _):
                    return symbol
                }
            }
        }
        
        func getPriority() -> Int {
            switch self {
            case .UnaryOperation(_, let priority, _):
                return priority
            case .BinaryOparation( _, let priority, _):
                return priority
            }
        }
    }
    
    private var knowOps = [String: Operation]()
    private var operandStack = [Double]()
    private var operatorStack = [Operation]()
    
    init() {
        func learnOp(op: Operation) {
            knowOps[op.description] = op
        }
        learnOp(Operation.BinaryOparation("✕", 2, *))
        learnOp(Operation.BinaryOparation("÷", 2) {$1 / $0})
        learnOp(Operation.BinaryOparation("+", 1, +))
        learnOp(Operation.BinaryOparation("-", 1) {$1 - $0})
        learnOp(Operation.UnaryOperation("√", 3, sqrt))
    }
    
    func pushOperand(operand: Double) {
        operandStack.append(operand)
        println("\(operandStack), \(operatorStack)")
    }
    
    func pushOperatorAgain(op: String) {
        operatorStack.removeLast()
        operatorStack.append(knowOps[op]!)
        println("\(operandStack), \(operatorStack)")
    }
    
    func pushOperator(op: String) -> Double? {
        if !operatorStack.isEmpty {
            if let lastOp = operatorStack.last {
                if let currentOp = knowOps[op] {
                    let result = lastOp.getPriority() - currentOp.getPriority()
                    if (result > 0) {
                        let evaluateValue = evaluate()
                        operatorStack.append(currentOp)
                        return evaluateValue
                    } else if (0 == result) {
                        let evaluateValue = evaluateOneStep()
                        operatorStack.append(currentOp)
                        return evaluateValue
                    } else {
                        operatorStack.append(knowOps[op]!)
                        println("\(operandStack), \(operatorStack)")
                    }
                }
            }
        } else {
            operatorStack.append(knowOps[op]!)
            println("\(operandStack), \(operatorStack)")
        }
        if 3 == operatorStack.last!.getPriority() {
            let evaluateValue = evaluate()
            return evaluateValue
        }
        return nil
    }
    
    private func evaluate(operandStack: [Double], operatorStack: [Operation]) -> (result: Double?, remainingOperand: [Double], remainingOperator: [Operation]) {
        
        var result : Double = 0
        var remainingOperand = operandStack
        var remainingOperator = operatorStack
        
        if !remainingOperand.isEmpty && !remainingOperator.isEmpty {
            while !remainingOperator.isEmpty {
                let op = remainingOperator.removeLast()
                switch op {
                case .UnaryOperation(_, _, let operation):
                    result = operation(remainingOperand.removeLast())
                    remainingOperand.append(result)
                case .BinaryOparation(_, _, let operation):
                    if remainingOperand.count > 1 {
                        result = operation(remainingOperand.removeLast(), remainingOperand.removeLast())
                        remainingOperand.append(result)
                    } else {
                        break
                    }
                }
            }
            return (result, remainingOperand, remainingOperator)
        } else if (!remainingOperand.isEmpty) {
            result = remainingOperand.last!
            return (result, remainingOperand, remainingOperator)
        }
        
        return (nil, operandStack, operatorStack)
    }
    
    private func evaluateOneStep(operandStack: [Double], operatorStack: [Operation]) -> (result: Double?, remainingOperand: [Double], remainingOperator: [Operation]) {
        
        var result : Double = 0
        var remainingOperand = operandStack
        var remainingOperator = operatorStack
        
        if !remainingOperand.isEmpty && !remainingOperator.isEmpty {
            if !remainingOperator.isEmpty {
                let op = remainingOperator.removeLast()
                switch op {
                case .UnaryOperation(_, _, let operation):
                    result = operation(remainingOperand.removeLast())
                    remainingOperand.append(result)
                case .BinaryOparation(_, _, let operation):
                    if remainingOperand.count > 1 {
                        result = operation(remainingOperand.removeLast(), remainingOperand.removeLast())
                        remainingOperand.append(result)
                    } else {
                        break
                    }
                }
            }
            return (result, remainingOperand, remainingOperator)
        } else if (!remainingOperand.isEmpty) {
            result = remainingOperand.last!
            return (result, remainingOperand, remainingOperator)
        }
        
        return (nil, operandStack, operatorStack)
    }
    
    func evaluateOneStep() -> Double? {
        let (result, remainingOperand, remainingOperator) = evaluateOneStep(operandStack, operatorStack: operatorStack)
        println("\(operandStack), \(operatorStack) = \(result) with \(remainingOperand), \(remainingOperator) left")
        operandStack = remainingOperand
        operatorStack = remainingOperator
        return result
    }
    
    func evaluate() -> Double? {
        let (result, remainingOperand, remainingOperator) = evaluate(operandStack, operatorStack: operatorStack)
        println("\(operandStack), \(operatorStack) = \(result) with \(remainingOperand), \(remainingOperator) left")
        operandStack = remainingOperand
        operatorStack = remainingOperator
        return result
    }
    
    func clear() {
        operandStack.removeAll(keepCapacity: false)
        operatorStack.removeAll(keepCapacity: false)
    }
}
