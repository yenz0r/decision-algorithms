//
//  ViewController.swift
//  test-1
//
//  Created by yenz0redd on 14.02.2020.
//  Copyright © 2020 yenz0redd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Subtypes

    enum InputType {
        case classes, objects, signs
    }

    enum AnimationState {
        case start, stop
    }

    // MARK: - IBOutlet variables

    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resultContainerView: UIView!
    @IBOutlet weak var loaderView: UIActivityIndicatorView!

    // MARK: - Private variables

    private var numberOfClasses = 0
    private var numberOfObjects = 0
    private var numberOfSigns = 0

    private var functions = [Function]()
    private var persiptron: Persiptron!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureContainerView()
        self.configureLoaderView()

        self.resultTextView.isEditable = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        self.view.endEditing(true)
    }

    // MARK: - Configuration

    private func configureLoaderView() {
        self.loaderView.style = .large
        self.loaderView.hidesWhenStopped = true
    }

    private func configureContainerView() {
        self.resultContainerView.layer.cornerRadius = 10
        self.resultContainerView.layer.borderColor = UIColor.red.withAlphaComponent(0.3).cgColor
        self.resultContainerView.layer.borderWidth = 1
        self.resultContainerView.clipsToBounds = true
    }

    // MARK: - IBActions

    @IBAction func numOfClassesEdited(_ sender: UITextField) {
        self.handleTextFieldEditing(sender, for: .classes)
    }

    @IBAction func numOfObjectsEdited(_ sender: UITextField) {
        self.handleTextFieldEditing(sender, for: .objects)
    }

    @IBAction func numOfSigns(_ sender: UITextField) {
        self.handleTextFieldEditing(sender, for: .signs)
    }

    @IBAction func startButtonTapped(_ sender: UIButton) {
        guard
            self.numberOfSigns > 0,
            self.numberOfObjects > 0,
            self.numberOfClasses > 0 else {
                self.showAlert(with: "Некорректные входные данные")
                return
        }

        guard self.numberOfObjects >= self.numberOfClasses else {
            self.showAlert(with: "Число объектов не может быть ниже числа классов")
            return
        }

        self.handleStartButtonTap()
    }

    // MARK: - Private UI functions

    private func handleTextFieldEditing(_ sender: UITextField, for type: InputType) {
        var resultNumber = 0
        if
            let text = sender.text,
            let number = Int(text),
            number > 0 {
                resultNumber = number
        }

        switch type {
        case .classes:
            self.numberOfClasses = resultNumber

        case .objects:
            self.numberOfObjects = resultNumber

        case .signs:
            self.numberOfSigns = resultNumber
        }
    }

    private func showAlert(with text: String) {
        let alertController = UIAlertController(
            title: "Внимание",
            message: text,
            preferredStyle: .alert
        )

        let alertAction = UIAlertAction(
            title: "Ok",
            style: .default,
            handler: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }
        )

        alertController.addAction(alertAction)

        self.present(alertController, animated: true, completion: nil)
    }

    private func animateProgress(_ state: AnimationState) {
        switch state {
        case .start:
            self.loaderView.startAnimating()
        case .stop:
            self.loaderView.stopAnimating()
        }
    }

    private func handleStartButtonTap() {
        self.persiptron = Persiptron(
            classCount: self.numberOfClasses,
            vectorsSize: self.numberOfSigns + 1
        )

        var vectors = self.getRandomVectors()

        self.animateProgress(.start)
        DispatchQueue.global(qos: .userInteractive).async {
            self.functions = self.persiptron.getSeparateFunctions(vectors: &vectors)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.animateProgress(.stop)
                if self.persiptron.warning {
                    self.showAlert(with: "Кол-во операций превысило 10000!")
                }
                self.printResult(vectors: vectors)
            }
        }
    }

    private func printResult(vectors: [[Vector]]) {
        resultTextView.text = ""
        printTeachingResult(vectors: vectors)
        resultTextView.text += "\n\nРазделяющие функции:\n"
        printFunctions()
    }

    private func printFunctions() {
        for i in 0..<self.numberOfClasses {
            resultTextView.text += "d(\(i+1)) = "

            for j in 0..<self.numberOfSigns {

                if j != 0 && self.functions[i].elements[j] >= 0 {
                    resultTextView.text += " + "
                }
                resultTextView.text += "\(self.functions[i].elements[j]) * x\(j+1) "
            }

            if functions[i].elements[self.numberOfSigns] >= 0 {
                resultTextView.text += " + "
            }

            resultTextView.text += "\(self.functions[i].elements[self.numberOfSigns])\n"
        }
    }

    private func printTeachingResult(vectors: [[Vector]]) {
        for i in 0..<self.numberOfClasses {
            resultTextView.text += "\(i + 1) Класс:\n"

            for j in 0..<self.numberOfObjects {
                resultTextView.text += "("

                for k in 0..<self.numberOfSigns {
                    resultTextView.text += "\(vectors[i][j].elements[k]); "
                }

                resultTextView.text += ")\n"
            }
        }
    }

    // MARK: - Private logic functions

    private func getRandomVectors() -> [[Vector]] {
        var result = [[Vector]]()

        for i in 0..<self.numberOfClasses {
            let vectors = [Vector]()
            result.append(vectors)

            for _ in 0..<self.numberOfObjects {
                let vector = Vector(with: self.numberOfSigns+1)

                for k in 0..<self.numberOfSigns {
                    vector.elements[k] = Int.random(in: -10...10)
                }
                vector.elements[self.numberOfSigns] = 1
                result[i].append(vector)
            }
        }

        return result
    }

}

// MARK: - UITextFieldDelegate implementation

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}
