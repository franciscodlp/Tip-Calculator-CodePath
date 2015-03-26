//
//  SettingsViewController.swift
//  Tip Calculator CodePath
//
//  Created by Francisco de la Pena on 3/16/15.
//  Copyright (c) 2015 ___TwisterLabs___. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // IBOutlets

    @IBOutlet var taxRateTextField: UITextField!            // Setting: Local Tax Rate
    
    @IBOutlet var minTipTextField: UITextField!             // Setting: Lower Tax Rate Limit when calculating tip rate
    
    @IBOutlet var maxTipTextField: UITextField!             // Setting: Higher Tax Rate Limit when calculating tip rate
    
    @IBOutlet var lowFixTipTextField: UITextField!          // Setting: User defined fix tip rate
    
    @IBOutlet var midFixTipTextField: UITextField!          // Setting: User defined fix tip rate
    
    @IBOutlet var highFixTipTextField: UITextField!         // Setting: User defined fix tip rate
    
    @IBOutlet var useFixTipSwitch: UISwitch!                // Setting: 0: Use Algorithm to calc tip    1: Use predefined tip rates
    
    @IBOutlet var tipOnTaxesSegCon: UISegmentedControl!     // Setting: 0: Calc Tip BEFORE taxes        1: Calc Tip AFTER taxes
    
    @IBOutlet var roundTotalSegCon: UISegmentedControl!     // Setting: 0: NOP  1: Round UP 2: Round Down (to the closes Int)
    
    @IBOutlet var fixTipRatesView: UIView!
    
    @IBOutlet var percentSimbols: [UILabel]!                // Label: Access required to change format based on paramenters
    
    @IBOutlet var tipRateLimitSimbols: [UILabel]!           // Label: Access required to change format based on paramenters
    
    // Global Variables
   
    var sharedDefaultObject: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    
    override func viewDidLoad() {
        
        println("SettingsViewController: " + "viewDidLoad")
        
        super.viewDidLoad()
        
        // Adding 2 Gesture Recognizarers:
        // - UITapGestureRecognizer: To hide keyboard after editing an TextField by tapping anywhere on the decvice's screen
        // - UISwipeGestureRecognizer: To transition from Settings View Controller to Main View Controller when swiping RIGHT
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapHandler"))
        
        var swipeRightRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeHandler:")
        
        swipeRightRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        
        self.view.addGestureRecognizer(swipeRightRecognizer)
 
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        println("SettingsViewController: " + "viewWillAppear")
        
        self.loadDataToFields()
        
        self.configuration()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // Load Data to UI Elements based on stored configuration
    
    func loadDataToFields() {
        
        // Load data - Segmented Controls
        
        tipOnTaxesSegCon.selectedSegmentIndex = (sharedDefaultObject.objectForKey("tipOnTax")! as Bool) ? 1 : 0
        
        roundTotalSegCon.selectedSegmentIndex = sharedDefaultObject.objectForKey("roundTotal")! as Int
        
        // Load data - Switch Status
        
        useFixTipSwitch.on = sharedDefaultObject.objectForKey("useFixTip")! as Bool
        
        // Load Data - Text Fields
        
        if sharedDefaultObject.objectForKey("SettingsInitialized") as Bool {
            
            taxRateTextField.text = sharedDefaultObject.objectForKey("taxRate") as String
            
            minTipTextField.text = sharedDefaultObject.objectForKey("minTip") as String
            
            maxTipTextField.text = sharedDefaultObject.objectForKey("maxTip") as String
            
        }
        
        var fixTipRates: [String] = sharedDefaultObject.objectForKey("fixTipRates") as [String]
        
        lowFixTipTextField.text = fixTipRates[0]
        
        midFixTipTextField.text = fixTipRates[1]
        
        highFixTipTextField.text = fixTipRates[2]
        
    }

    
    // Resings First Responder if a tap gesture is detected outside the TextField when editing it (to hide keyboard)
    
    func tapHandler() {
        
        self.view.endEditing(true)
        
    }
    
    
    // Performs segue (Settings VC to Main VC) if a RIGHT swipe is detected
    
    func swipeHandler(sender: UISwipeGestureRecognizer) {
        
        if sender.direction.rawValue == 1 && validateSettings() {
            
            self.presentingViewController?.viewWillAppear(false)
            
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
            
        }

    }
    
    
    // Configures UI Elements
    
    func configuration() {
        
        // TextFields Config
        
        self.configTextField([taxRateTextField, minTipTextField, maxTipTextField], color: UIColor.whiteColor(), mode: true)

        self.configSwitch(useFixTipSwitch)
        
        // Segmented Control Config
        
        tipOnTaxesSegCon.addTarget(self, action: "configSegmentedControls:", forControlEvents: UIControlEvents.ValueChanged)
        
        roundTotalSegCon.addTarget(self, action: "configSegmentedControls:", forControlEvents: UIControlEvents.ValueChanged)

        // Switch Config
        
        useFixTipSwitch.addTarget(self, action: "configSwitch:", forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    
    // Configs Text Fields Appearance
    
    func configTextField(textFieldArray: [UITextField], color: UIColor = UIColor.whiteColor().colorWithAlphaComponent(0.3), mode: Bool = false) {
        
        let colorPlaceHolder: UIColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        
        for textField in textFieldArray {
        
            if let tmp = textField.placeholder {
                
                textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: colorPlaceHolder])
                
            }
            
            textField.enabled = mode
            
            textField.textColor = color
            
            textField.keyboardType = UIKeyboardType.DecimalPad
            
            textField.layer.borderColor = color.CGColor
            
            textField.layer.borderWidth = 1.0
            
            textField.layer.cornerRadius = 6.0
            
        }
    
    }
    
    
    // Configs Segmented Controls Appearance
    
    func configSegmentedControls(segCon: UISegmentedControl) {
        
        self.view.endEditing(true)
        
        if segCon.tag == 0 {
            
            sharedDefaultObject.setBool(tipOnTaxesSegCon.selectedSegmentIndex == 0 ? false : true, forKey: "tipOnTax")
            
        } else {
            
            sharedDefaultObject.setInteger(roundTotalSegCon.selectedSegmentIndex, forKey: "roundTotal")
            
        }
        
        sharedDefaultObject.synchronize()
        
    }
    
    
    // Configs UISwitch Appearance and its Effects in other UI Elements
    
    func configSwitch(sender: UISwitch) {
        
        sharedDefaultObject.setBool(useFixTipSwitch.on, forKey: "useFixTip")
        
        sharedDefaultObject.synchronize()
        
        if sender.on {      // Case ON
            
            UIView.animateWithDuration(1.0, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                
                self.configTextField([self.lowFixTipTextField, self.midFixTipTextField, self.highFixTipTextField], color: UIColor.whiteColor(), mode: true)
                
                for label in self.percentSimbols {
                    
                    label.textColor = UIColor.whiteColor()
                    
                }
                
                self.configTextField([self.minTipTextField, self.maxTipTextField], color: UIColor.whiteColor().colorWithAlphaComponent(0.3), mode: false)
                
                for label in self.tipRateLimitSimbols {
                    
                    label.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
                    
                }
                
                
            }, completion: nil)
            
        } else {            // Case OFF
            
            UIView.animateWithDuration(1.0, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                
                self.configTextField([self.lowFixTipTextField, self.midFixTipTextField, self.highFixTipTextField], color: UIColor.whiteColor().colorWithAlphaComponent(0.3), mode: false)
                
                for simbol in self.percentSimbols {
                    
                    simbol.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
                    
                }
                
                self.configTextField([self.minTipTextField, self.maxTipTextField], color: UIColor.whiteColor(), mode: true)
                
                for label in self.tipRateLimitSimbols {
                    
                    label.textColor = UIColor.whiteColor()
                    
                }
                
                }, completion: nil)
            
        }
        
    }

    
    // Validate fields before returning to Main VC
    
    func validateSettings() -> Bool {
    
        if taxRateTextField.text == "" {            // Local Tax Rate MUST be initialized
            
            var alert: UIAlertView = UIAlertView(title: "Incomplete Settings", message: "Enter Tax Rate for your current location", delegate: nil, cancelButtonTitle: "OK")
            
            alert.show()
            
            return false

        } else if useFixTipSwitch.on {              // If useFixTipSwitch == ON -> Low, Mid & High MUST have value different from ""
            
            if lowFixTipTextField.text == "" || midFixTipTextField.text == "" || highFixTipTextField.text == "" {
                
                var alert: UIAlertView = UIAlertView(title: "Incomplete Settings", message: "Enter all Fix Tip Rates", delegate: nil, cancelButtonTitle: "OK")
                
                alert.show()
                
                return false
                
            }
            
        } else {
            
            if minTipTextField.text == "" {         // If useFixTipSwitch == OFF -> min & max tip limits MUST have value different from ""
            
                var alert: UIAlertView = UIAlertView(title: "Incomplete Settings", message: "Enter Min Tip % ", delegate: nil, cancelButtonTitle: "ok!")
            
                alert.show()
            
                return false
                
            } else if maxTipTextField.text == "" {
                
                var alert: UIAlertView = UIAlertView(title: "Incomplete Settings", message: "Enter Max Tip %", delegate: nil, cancelButtonTitle: "ok!")
                
                alert.show()
                
                return false
                
            }
            
        }
        
        sharedDefaultObject.setObject(taxRateTextField.text, forKey: "taxRate")
        
        sharedDefaultObject.setObject(minTipTextField.text, forKey: "minTip")
        
        sharedDefaultObject.setObject(maxTipTextField.text, forKey: "maxTip")
        
        sharedDefaultObject.setBool(true, forKey: "SettingsInitialized")

        sharedDefaultObject.setObject([lowFixTipTextField.text, midFixTipTextField.text, highFixTipTextField.text], forKey: "fixTipRates")

        sharedDefaultObject.synchronize()
        
        return true
        
    }
    
    
    // Button behave exactly as "Swipe Right Gesture"
    
    @IBAction func doneButton(sender: UIButton) {
        
        if validateSettings() {
            
            self.presentingViewController?.viewWillAppear(false)
            
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
   
                
            })
            
        }
        
    }
    
    

}
