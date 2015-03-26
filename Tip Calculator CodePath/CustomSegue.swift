//
//  CustomSegue.swift
//  Tip Calculator CodePath
//
//  Created by Francisco de la Pena on 3/20/15.
//  Copyright (c) 2015 ___TwisterLabs___. All rights reserved.
//

import UIKit

class CustomSegue: UIStoryboardSegue {

    override func perform() {
        
        let sourceViewController: UIViewController = self.sourceViewController as UIViewController
        
        let destinationViewController: UIViewController = self.destinationViewController as UIViewController
        
        if self.identifier == "MainVCToSettingsVC" {

            destinationViewController.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
            
            destinationViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        } else {
            
            destinationViewController.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
            
            destinationViewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        }
        
        sourceViewController.presentViewController(destinationViewController, animated: true, completion: nil)
        println("yeeeeees")
        
    }
}
