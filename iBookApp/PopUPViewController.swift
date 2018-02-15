//
//  PopUPViewController.swift
//  iBookApp
//
//  Created by Stephane Darcy SIMO MBA on 14/02/2018.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit

class PopUPViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var _view: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addButton.layer.cornerRadius = 8
        addButton.layer.shadowOpacity = 3
        _view.layer.cornerRadius = 5
        textField.delegate = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        self.view.isUserInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Tap Gesture Recognizer
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: self._view))! {
            return false
        }
        return true
    }
    
    // MARK: - Add Action
    
    @IBAction func addAction(_ sender: Any) {
        if (!(textField.text?.isEmpty)!) {
            ModelController.shared?.addData(data: textField.text!)
            self.willMove(toParentViewController: nil)
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }
    }
    
    // MARK: - TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
