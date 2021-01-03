//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Chien on 2017/6/13.
//  Copyright © 2017年 Chien. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelResult: UILabel!

    let calModel = CalculatorModel() // calModel 跟隨著 CalculatorViewController 一起存活

    override func viewDidLoad() {
        super.viewDidLoad()

        self.labelResult.layer.cornerRadius = 20.0
        self.labelResult.clipsToBounds = true

        self.labelDescription.layer.cornerRadius = 20.0
        self.labelDescription.clipsToBounds = true
    }

    @IBAction func clickButton(_ sender: UIButton) {
        guard let buttonLabel = sender.currentTitle else {
            self.labelResult.text = "Error"
            return
        }

        calModel.setUp(buttonLabel: buttonLabel)
        calModel.doCalculator()

        let (newDescription, newResult) = calModel.getFinalBack()
        self.labelDescription.text = newDescription
        self.labelResult.text = newResult
    }
}
