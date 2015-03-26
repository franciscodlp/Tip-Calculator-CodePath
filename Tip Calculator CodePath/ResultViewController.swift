//
//  ResultViewController.swift
//  Tip Calculator CodePath
//
//  Created by Francisco de la Pena on 3/16/15.
//  Copyright (c) 2015 ___TwisterLabs___. All rights reserved.
//

import UIKit
import CoreMotion

class ResultViewController: UIViewController, UICollisionBehaviorDelegate {

    // IBOutlets
    
    @IBOutlet var totalCheckLabel: UILabel!
    
    @IBOutlet var tipValueLabel: UILabel!
    
    @IBOutlet var tipRateLabel: UILabel!
    
    @IBOutlet var gotItButton: UIButton!
    
    @IBOutlet var secretGameButton: UIButton!
    
    @IBOutlet var winnerBadge: UIImageView!
    
    // Global Variables
    
    var formatter: NSNumberFormatter = NSNumberFormatter()
    
    var sharedDefaultObject: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    // Secret Game Variables
    
    var secretGameEnabled: Bool = true
    
    var samplingTimer: NSTimer!
    
    var gameTimer: NSTimer!
    
    var motionManager: CMMotionManager!
    
    var accelDataOld: CMAcceleration!
    
    var accelDataNew: CMAcceleration!
    
    var shakeCounter = 0
    
    var animator: UIDynamicAnimator!
    
    var gravity: UIGravityBehavior!
    
    var collision: UICollisionBehavior!
    
    @IBAction func gotItButton(sender: UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    
    }
    
    
    override func viewDidLoad() {
        
        println("ResultViewController: " + "viewDidLoad")
        
        super.viewDidLoad()
        
        // Secret Game Parameter Initialization
        
        secretGameEnabled = true
        
        animator = UIDynamicAnimator(referenceView: self.view)
        
        gravity = UIGravityBehavior(items: [secretGameButton])
        
        collision = UICollisionBehavior(items: [secretGameButton])
        
        collision.translatesReferenceBoundsIntoBoundary = true
        
        collision.collisionDelegate = self
        
        // Results UI Update
        
        formatter.locale = NSLocale.currentLocale()
        
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        
        var strTotalCheck = formatter.stringFromNumber(NSNumber(float: sharedDefaultObject.valueForKey("totalCheck") as Float))!
        
        var strTipValue = formatter.stringFromNumber(NSNumber(float: sharedDefaultObject.valueForKey("tipValue") as Float))!
        
        var tipRate = (sharedDefaultObject.valueForKey("tipRate") as NSString)
        
        totalCheckLabel.text = strTotalCheck
        
        tipValueLabel.text = strTipValue
        
        tipRateLabel.text = "( " + tipRate + " )%"
     
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        gotItButton.enabled = true
        
        secretGameButton.hidden = true
        
        winnerBadge.hidden = true
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Function (UIResponder) that uses a motion event (MotionShake) to initilize a secret game that may boost the tip by 5%. The game uses a timer and the accelerometer.
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
        println("motionBegan")
        if motion == UIEventSubtype.MotionShake && secretGameEnabled {
            println("Activating secret Game")
            accelDataOld = CMAcceleration(x: 0.0, y: 0.0, z: 0.0)
            
            accelDataNew = CMAcceleration(x: 0.0, y: 0.0, z: 0.0)
            
            shakeCounter = 0
            
            secretGameEnabled = false
            
            secretGameButton.hidden = false
            
            motionManager = CMMotionManager()
            
            motionManager.accelerometerUpdateInterval = 0.1
            
        }
    }
    
    
    // Secret Button Pressed: Activates the game and starts an animation that uses Gravity & Collisions from the UIDynamics.
    // It makes the button bounce around the screen while shaking the device (the movement of the button it's independent the shaking movement)
    
    @IBAction func secretGame(sender: UIButton) {
        println("secretGame")
        
        gotItButton.enabled = false
        
        samplingTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "tipBooster", userInfo: nil, repeats: true)
        
        gameTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "secretGameStop", userInfo: nil, repeats: false)
        
        motionManager.startAccelerometerUpdates()
        
        secretGameButton.enabled = false
        
        animator.addBehavior(gravity)
        
        animator.addBehavior(collision)
        

        
    }
    
    
    // This func is fired by the timer. It reads data from the accelerometer: (z,y,z) accelerations
    // It compares the result with the previously stored data to detect a change in acceleration direction ("a Shake")
    // A shake is considered as the change of sign ( - -> + || + -> -) in any of the 3-axis (x, y, z)

    func tipBooster() {
        
        if let data: CMAccelerometerData = motionManager.accelerometerData {
            
            accelDataOld = accelDataNew
            accelDataNew = data.acceleration
            
            // check for sign changes
            if (accelDataNew.x.isSignMinus != accelDataOld.x.isSignMinus) ||
                (accelDataNew.y.isSignMinus != accelDataOld.y.isSignMinus) ||
                (accelDataNew.z.isSignMinus != accelDataOld.z.isSignMinus ) {
                    
                    println([accelDataNew.x, accelDataOld.x])
                    println([accelDataNew.y, accelDataOld.y])
                    println([accelDataNew.z, accelDataOld.z])
                    println("--------------------------------")
                    shakeCounter++
                    
                    println("Shakes:\(shakeCounter)")
                    
            }

        }
        
    }
    
    // Stops the game a reset some of the parameters. 
    // It displays the result Winner or Loser and, recalculate the bill data if necessary
    
    func secretGameStop() {
        
        samplingTimer.invalidate()
        
        gameTimer.invalidate()
        
        println("secretGameStop")
        
        animator.removeAllBehaviors()
        
        gotItButton.enabled = true
        
        samplingTimer.invalidate()
        
        gameTimer.invalidate()
        
        secretGameEnabled = true
        
        secretGameButton.hidden = true
        
        println("Total Shakes: \(shakeCounter)")
        
        var gameMessage: [String] = shakeCounter > 50 ? ["Congratulations!!!", "Your tip just increased 5 % !!"] : ["Sorry!!!", "( \(shakeCounter) / 50 ) Best luck next time!!"]
        
        var alert: UIAlertView = UIAlertView(title: gameMessage[0], message: gameMessage[1], delegate: nil, cancelButtonTitle: "OK")
        
        if shakeCounter > 50 {
            
            self.calcBoostedValues()
            
            winnerBadge.hidden = false
        
        } else {
            
            alert.show()
            
        }
    }
    
    // If the user wins the game the tip is increase by 5% and values recalculated using CalcBoostedValues()
    
    func calcBoostedValues() {
        var formatter = NSNumberFormatter()
        
        formatter.maximumFractionDigits = 1
        
        formatter.minimumIntegerDigits = 1
        
        var subTotal: Float = sharedDefaultObject.objectForKey("subTotal") as Float
        println("subTotal: \(subTotal)")
        
        var taxes: Float = sharedDefaultObject.objectForKey("taxes") as Float
        println("taxes: \(taxes)")
        
        var tipValue: Float = sharedDefaultObject.objectForKey("tipValue") as Float
        println("tipValue: \(tipValue)")
        
        var tipRate: Float = (sharedDefaultObject.objectForKey("tipRate") as NSString).floatValue + 5.0
        println("tipRate: \(tipRate)")
        
        var calcBase  = (sharedDefaultObject.objectForKey("tipOnTax") as Bool) ? (subTotal + taxes) : subTotal
        println("calcBase: \(calcBase)")
        
        tipValue = calcBase * tipRate / 100
        println("TipValue: \(tipValue)")
        
        var total = subTotal + taxes + tipValue
        println("Total: \(total)")
        
        
        // Modifiers
        switch sharedDefaultObject.objectForKey("roundTotal") as Int {
            
        case 1:
            
            total = ceil(total)
            
        case 2:
            
            total = floor(total)
            
        default:
            
            break
            
        }

        tipValue = (total - subTotal - taxes)
        
        tipRate = calcBase == 0 ? 0 : (tipValue / calcBase)
        
        
        totalCheckLabel.text = self.formatter.stringFromNumber(NSNumber(float: total))
        
        tipValueLabel.text = self.formatter.stringFromNumber(NSNumber(float: tipValue))
        
        tipRateLabel.text = "( " + formatter.stringFromNumber(NSNumber(float: tipRate * 100))! + " )%"

    }
    
    
    // Function that handlers the collision behavior applied to the animator that controls de movement of the Secret Game while running
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        
        var x = p.x
        
        var y = p.y
        
        var mult: Double = 20
        
        if y <= 3 {             // Upper Boundary
            
//            println("Collision Detected: UP")
            
            gravity.gravityDirection = CGVector(dx: CGFloat(mult * (Double(arc4random_uniform(21)) / 10.0 - 1)), dy: CGFloat(mult * (Double(arc4random_uniform(11)) / 10.0)))
            
        } else if y >= 565 {    // Lower Boundary
            
//            println("Collision Detected: Down")
            
            gravity.gravityDirection = CGVector(dx: CGFloat(mult * (Double(arc4random_uniform(21)) / 10.0 - 1)), dy: CGFloat(mult * (Double(arc4random_uniform(11)) / 10.0 - 1)))
            
        } else if x <= 3 {      // Left Boundary
            
//            println("Collision Detected: Left")
         
            gravity.gravityDirection = CGVector(dx: CGFloat(mult * (Double(arc4random_uniform(11)) / 10.0)), dy: CGFloat(mult * (Double(arc4random_uniform(21)) / 10.0 - 1)))
            
        } else if x >= 317 {    // Right Boundary
            
//            println("Collision Detected: Right")
           
            gravity.gravityDirection = CGVector(dx: CGFloat(mult * (Double(arc4random_uniform(11)) / 10.0 - 1)), dy: CGFloat(mult * (Double(arc4random_uniform(21)) / 10.0 - 1)))
            
        }
        
//        println("New Direction: \([gravity.gravityDirection.dx, gravity.gravityDirection.dy)")
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
