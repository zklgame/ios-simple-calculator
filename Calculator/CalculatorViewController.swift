//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by zklgame on 15/7/23.
//  Copyright (c) 2015年 Zhu Kaili. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    // if the last buttn is also an operator, then replace it
    var isLastBtnAnOperator = false
    
    var brain = CalculatorBrain()

    @IBAction func appendDigit(sender: UIButton)
    {
        let digit = sender.currentTitle!
        isLastBtnAnOperator = false
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func evaluate()
    {
        if userIsInTheMiddleOfTypingANumber {
            brain.pushOperand(displayValue)
        }
        if let result = brain.evaluate() {
            displayValue = result
        } else {
            displayValue = 0
        }
        userIsInTheMiddleOfTypingANumber = false
        isLastBtnAnOperator = false
    }
    
    @IBAction func operate(sender: UIButton)
    {
        if userIsInTheMiddleOfTypingANumber {
            brain.pushOperand(displayValue)
            userIsInTheMiddleOfTypingANumber = false
        }
        if let operation = sender.currentTitle {
            if isLastBtnAnOperator {
                brain.pushOperatorAgain(operation)
            } else {
                isLastBtnAnOperator = true
                if let result = brain.pushOperator(operation) {
                    displayValue = result
                    isLastBtnAnOperator = false
                }
            }
            
        }
    }
    
    
    @IBAction func clear(sender: UIButton)
    {
        brain.clear()
        displayValue = 0
        userIsInTheMiddleOfTypingANumber = false
        isLastBtnAnOperator = false
    }
    
    var displayValue : Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }

}
