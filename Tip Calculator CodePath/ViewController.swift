//
//  ViewController.swift
//  Tip Calculator CodePath
//
//  Created by Francisco de la Pena on 3/16/15.
//  Copyright (c) 2015 ___TwisterLabs___. All rights reserved.
//

import UIKit
import QuartzCore



class ViewController: UIViewController {
    
    // IBOutlets
                                                            
    @IBOutlet var billValueTextField: UITextField!          // User Input (Check)
    
    @IBOutlet var guestsTextField: UITextField!             // User Input (Number of payees or guests)
    
    @IBOutlet var venueTypeSegCon: UISegmentedControl!      // User Input (Type of venue. From 1 - the takiest to 5 - the fanciest)
    
    @IBOutlet var fixTipValuesSegCon: UISegmentedControl!   // User Input (User defiened tax rates)
    
    @IBOutlet var qosSegCon: UISegmentedControl!            // User Input (Quality of service)
    
    @IBOutlet var venueTypeView: UIView!                    // View containing Label + Segemented control
    
    @IBOutlet var fixTipValuesView: UIView!                 // View containing Label + Segemented control
    
    @IBOutlet var qosView: UIView!                          // View containing Label + Segemented control
    
    @IBOutlet var guestsView: UIView!                       // View containing Label + Text Field
    
    // Global Variables
    
    var sharedDefaultObject: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    var formatter: NSNumberFormatter = NSNumberFormatter()
    
    // Segmented Controls Images
    
    var images: [UIImage] = [UIImage(named: "Fork_stroke")!, UIImage(named: "Fork_solid")!, UIImage(named: "Star_stroke")!, UIImage(named: "Star_solid")!]
    
    
    override func viewDidLoad() {
        
        println("ViewController: " + "viewDidLoad")

        super.viewDidLoad()
        
        var nc: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        nc.addObserver(self, selector: "finishEditingTextField_1", name: UITextFieldTextDidEndEditingNotification, object: billValueTextField)
        
        nc.addObserver(self, selector: "finishEditingTextField_2", name: UITextFieldTextDidEndEditingNotification, object: guestsTextField)
        
        // Adding 2 Gesture Recognizarers:
        // - UITapGestureRecognizer: To hide keyboard after editing an TextField by tapping anywhere on the decvice's screen
        // - UISwipeGestureRecognizer: To transition from Main View Controller to Settings View Controller when swiping LEFT
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapHandler"))
        
        var swipeLeftRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeHandler:")
        
        swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        
        self.view.addGestureRecognizer(swipeLeftRecognizer)
        
        self.initSequence()

        self.configuration()

    }
    
    
    override func viewWillAppear(animated: Bool) {
        println("ViewController: " + "viewWillAppear")
        
        self.hiddeableBlocksLocation()
        
        self.configSegmentedControls([venueTypeSegCon, qosSegCon, fixTipValuesSegCon])
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Creates Settings Data Set using User Defaults, Assings Initial values
    
    func initSequence() {
        println("ViewController: " + "initSequence")
        // Very first initialization
        
        if sharedDefaultObject.objectForKey("initialized") == nil {                         // Initialization Flag
            
            sharedDefaultObject.setBool(true, forKey: "initialized")                        // Main Initialization Flag
            
            sharedDefaultObject.setBool(false, forKey: "SettingsInitialized")               // Settings Initialization Flag
            
            sharedDefaultObject.setBool(false, forKey: "tipOnTax")                          // FALSE: Calculate Tip before Taxes, TRUE: Calulate Tip after Taxes
            
            sharedDefaultObject.setBool(false, forKey: "useFixTip")                         // FALSE: Use the app algorithm to calc Tip Rates, TRUE: Use user defiend Tip Rates
            
            sharedDefaultObject.setInteger(0, forKey: "roundTotal")                         // 0: NOP, 1: Total rounded to the closest Int above it 2: Total rounded to the closet Int below it
            
            sharedDefaultObject.setObject("1.0", forKey: "taxRate")                         // Local Tax Rate
            
            sharedDefaultObject.setObject("10.0", forKey: "minTip")                         // Min tip to use by the Algorithm - Tip won't ever be below this limit
            
            sharedDefaultObject.setObject("25.0", forKey: "maxTip")                         // Max tip to use by the Algorithm - Tip won't ever be above this limit
            
            sharedDefaultObject.setObject(["10", "18", "25"], forKey: "fixTipRates")        // User predefined (in Settings) tip rates
            
            sharedDefaultObject.setFloat(0.0, forKey: "totalCheck")                         // Total after taxes and tip
            
            sharedDefaultObject.setFloat(0.0, forKey: "tipValue")                           // Tip paid
            
            sharedDefaultObject.setObject("0.0", forKey: "tipRate")                         // Tip rated applied to bill
            
            sharedDefaultObject.setDouble(0.0, forKey: "monthTips")                         // Total amount of tips in the last month (or year)
            
            sharedDefaultObject.setFloat(0.0, forKey: "subTotal")                           // Total before taxes and tip
            
            sharedDefaultObject.setFloat(0.0, forKey: "taxes")                              // Taxes to apply to SubTotal
            
            sharedDefaultObject.synchronize()
            
        }
        
        billValueTextField.text = "$0.00"                                                   // Reset Bill Text Field
        
        guestsTextField.text = "1"                                                          // Reset Number of Guests Text Field
        
        venueTypeSegCon.selectedSegmentIndex = UISegmentedControlNoSegment                  // Reset Venue Type Segemented Control (none selected)
        
        qosSegCon.selectedSegmentIndex = UISegmentedControlNoSegment                        // Reset Quality of Service Segemented Control (none selected)
        
        fixTipValuesSegCon.selectedSegmentIndex = UISegmentedControlNoSegment               // Reset Fix Tip Values Segemented Control (none selected)
        
        self.configSegmentedControls([venueTypeSegCon, qosSegCon, fixTipValuesSegCon])
        
    }
    
    
    // Resings First Responder if a tap gesture is detected outside the TextField when editing it (to hide keyboard)
    
    func tapHandler() {
        println("ViewController: " + "tapHandler")
        self.view.endEditing(true)
        
    }
    

    // Performs segue (Main VC to Settings VC) if a LEFT swipe is detected
    
    func swipeHandler(sender: UISwipeGestureRecognizer) {
        println("ViewController: " + "swipeHandler")
        if sender.direction.rawValue == 2 {
            
            self.performSegueWithIdentifier("MainVCToSettingsVC", sender: nil)
            
        }
        
    }
    
    
    // Replaces an empty user's input with $0.00 (I'm not using Placeholders)
    
    func finishEditingTextField_1() {
        println("ViewController: " + "finishEditingTextField_1")
        billValueTextField.text = billValueTextField.text == "" ? "$0.00" : (formatter.stringFromNumber(NSNumber(float: (billValueTextField.text as NSString).floatValue)))!
        
    }
    
    // Replaces an empty user's input with 1 (I'm not using Placeholders)
    
    func finishEditingTextField_2() {
        println("ViewController: " + "finishEditingTextField_2")
        guestsTextField.text = guestsTextField.text == "" ? "1" : guestsTextField.text as NSString
        
    }
    

    // Configures UI Elements
    
    func configuration() {
        println("ViewController: " + "configuration")
        
        formatter.locale = NSLocale.currentLocale()
        
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        
        formatter.maximumIntegerDigits = 9
        
        
        // Tells images to ignore the Segmented Control Settings (e.g. color)
        
        for var i = 0; i < images.count; i++ {
            
            images[i] = images[i].imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            
        }

        // TextFields Config

        billValueTextField.keyboardType = UIKeyboardType.DecimalPad
        
        guestsTextField.keyboardType = UIKeyboardType.NumberPad
        
        guestsTextField.layer.borderWidth = 1.0
        
        guestsTextField.layer.cornerRadius = 6.0
        
        guestsTextField.layer.borderColor = UIColor.whiteColor().CGColor

        // Segmented Controls Config
        
        venueTypeSegCon.addTarget(self, action: "segmentedControlChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        qosSegCon.addTarget(self, action: "segmentedControlChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        fixTipValuesSegCon.addTarget(self, action: "segmentedControlChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    
    // Calls the proper config func. everytime the value of a Segmented control changes
    
    func segmentedControlChanged(sender: UISegmentedControl) {
        println("ViewController: " + "segmentedControlChanged")

        self.view.endEditing(true)              // Hides keyboard if user taps a SegmentedControl while editing TextFields
        
        self.configSegmentedControls([sender])
        
        
    }
    

    // Configures Segment Control Appearance
    
    func configSegmentedControls(segmentedControlArray: [UISegmentedControl]) {
        println("ViewController: " + "configSegmentedControls")
        for segmentedcontrol in segmentedControlArray {
            
            if segmentedcontrol.tag == 2 {                                                      // Segmented Control == FixTipValuesSegmentedControl
                
                var fixTipValues: [String] = sharedDefaultObject.objectForKey("fixTipRates")! as [String]
                
                for var i = 0; i < segmentedcontrol.numberOfSegments; i++ {
                    
                    segmentedcontrol.setTitle(fixTipValues[i], forSegmentAtIndex: i)
                    
                }
                
            } else {                                                                            // Segmented Control == venueTypeSegmentedControl OR QualityOfServiceSegmentedControl
                
                    if segmentedcontrol.selectedSegmentIndex == UISegmentedControlNoSegment {   // If NO Segment Selected
                        
                        for var i = 0; i < segmentedcontrol.numberOfSegments; i++ {
                            
                            segmentedcontrol.setImage(images[segmentedcontrol.tag * 2], forSegmentAtIndex: i)
                            
                        }
      
                    } else {

                        for var i = 0; i < segmentedcontrol.numberOfSegments; i++ {             // If a Segment Selected
                            
                            var imgAsset = (i <= segmentedcontrol.selectedSegmentIndex) ? (segmentedcontrol.tag * 2) + 1 : (segmentedcontrol.tag * 2)

                            segmentedcontrol.setImage(images[imgAsset], forSegmentAtIndex: i)
                            
                        }
                        
                    }
                
            }
            
        }
    }

    
    // Configures UI blocks Visibility
  
    func hiddeableBlocksLocation() {
        println("ViewController: " + "hiddeableBlocksLocation")
        if sharedDefaultObject.objectForKey("useFixTip")! as Bool {
            
            venueTypeView.hidden = true
            
            qosView.hidden = true
            
            fixTipValuesView.hidden = false
            
        } else {
            
            venueTypeView.hidden = false
            
            qosView.hidden = false
            
            fixTipValuesView.hidden = true
            
        }
        
    }
    
    // "Calculate Tip Button Action": It validates the input and calculate tip if possible

    @IBAction func buttonTapped(sender: UIButton) {
        println("ViewController: " + "buttonTapped")
        if self.validateInput() {
            
            self.calcTip()
            
        }

    }


    // Validate User Input before Calculates Tip

    func validateInput() -> Bool {
        
        println("ViewController: " + "validateInput")
        
        if !(sharedDefaultObject.objectForKey("SettingsInitialized") as Bool) {             // Checks whether essential Settings were initialized or not
            
            var alert: UIAlertView = UIAlertView(title: "Please, setup local taxes", message: "Go to settings > Tax Rate", delegate: nil, cancelButtonTitle: "OK")
            
            alert.show()
            
            return false
    
        } else if sharedDefaultObject.objectForKey("useFixTip") as Bool {
            
            if fixTipValuesSegCon.selectedSegmentIndex == UISegmentedControlNoSegment {     // Checks whether user provided enough info in the Main View Controller
                
                var alert: UIAlertView = UIAlertView(title: "psss... psss...", message: "Pick a tip rate!", delegate: nil, cancelButtonTitle: "OK")
                
                alert.show()
                
                return false
                
            }
            
        } else {
        
            if venueTypeSegCon.selectedSegmentIndex == UISegmentedControlNoSegment {        // Checks whether user provided enough info in the Main View Controller
                
                var alert: UIAlertView = UIAlertView(title: "psss... psss...", message: "How fancy is the venue?", delegate: nil, cancelButtonTitle: "OK")
                
                alert.show()
                
                return false
                
            } else if qosSegCon.selectedSegmentIndex == UISegmentedControlNoSegment {       // Checks whether user provided enough info in the Main View Controller
                
                var alert: UIAlertView = UIAlertView(title: "psss... psss...", message: "How awesome was the service?", delegate: nil, cancelButtonTitle: "OK")
                
                alert.show()
                
                return false
                
            }
            
        }
        
        return true
        
    }
    
    
    // Calc App Output Values

    func calcTip() {
        println("ViewController: " + "calcTip")
        
        // Fix Values
        var guests = (guestsTextField.text as NSString).floatValue
        
        var subTotal: Float = (formatter.numberFromString(billValueTextField.text as String)!.floatValue) / guests
        
        var taxRate = (sharedDefaultObject.objectForKey("taxRate") as NSString).floatValue / 100
        
        var taxValue = subTotal * taxRate
        
        ////////////////
        
        var calcBase  = (sharedDefaultObject.objectForKey("tipOnTax") as Bool) ? (subTotal + taxValue) : subTotal
        
        var tipRate: Float = 0.0
        
        var gap: Float = 0.0
        
        
        if sharedDefaultObject.objectForKey("useFixTip") as Bool {
            
            tipRate = ((sharedDefaultObject.objectForKey("fixTipRates") as [NSString])[fixTipValuesSegCon.selectedSegmentIndex]).floatValue / 100
            
        } else {
            
            gap = ((sharedDefaultObject.objectForKey("maxTip") as NSString).floatValue / 100)
                - ((sharedDefaultObject.objectForKey("minTip") as NSString).floatValue / 100)
            
            var venueRating = Float(venueTypeSegCon.selectedSegmentIndex)
            
            var qosRating = Float(qosSegCon.selectedSegmentIndex)

            var op1 = (sharedDefaultObject.objectForKey("minTip") as NSString).floatValue / 100
            
            var op2 =  venueRating / Float(venueTypeSegCon.numberOfSegments)
            
            var op3 =  qosRating / ( Float(venueTypeSegCon.numberOfSegments) * Float(qosSegCon.numberOfSegments) )
            
            tipRate = (op1 + (gap * (op2 + op3)))
            
        }
        
        var tipValue = ( calcBase * tipRate )
        
        var total = subTotal + taxValue + tipValue

        switch sharedDefaultObject.objectForKey("roundTotal") as Int {
            
        case 1:
            
            total = ceil(total)
            
        case 2:
            
            total = floor(total)
            
        default:

            break
            
        }
        

        tipValue = (total - subTotal - taxValue)
        
        tipRate = calcBase == 0 ? 0 : (tipValue / calcBase)
        
        var decFormatter: NSNumberFormatter = NSNumberFormatter()
        
        decFormatter.maximumFractionDigits = 1
        
        decFormatter.minimumIntegerDigits = 1
        
        sharedDefaultObject.setFloat(subTotal, forKey: "subTotal")
        
        sharedDefaultObject.setFloat(taxValue, forKey: "taxes")
        
        sharedDefaultObject.setFloat(total, forKey: "totalCheck")
        
        sharedDefaultObject.setObject(decFormatter.stringFromNumber(NSNumber(float: tipRate * 100)), forKey: "tipRate")
        
        sharedDefaultObject.setFloat(tipValue, forKey: "tipValue")
        
        sharedDefaultObject.synchronize()
        
        self.performSegueWithIdentifier("goToResults", sender: nil)
        
        println("exit calcTip()")
    }
    
}

