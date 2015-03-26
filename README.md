# Tip-Calculator-CodePath
(CodePath Prework)

This is an iOS Demo Application developped as part of the CodePath program application process. The app is a Tip Calculator that includes not only the basic features but a couple of optionals features

Time spent: 15 hours*


Completed user stories:

 * [x] **Required**: User can calculate the tip of a given check based on parameters defined in a Setting page **
 * [x] **Required**: Settings data is stored using NSUserefaults to avoid requiring setup after every restart of the app
 * [x] **Required**: The app uses common View Controller Lifecyce functions: viewWillApper, viewDidLoad, etc.
 
 * [x] **Optional**: User can navigate between the **Main VC** and the **Settings VC** both by **swipping** on the screen and using the **buttons** on the upper right corner of the screen
 * [x] **Optional**: User must rate the venue (Fancy-rate 1 to 5 forks) and the Quality of the service recived (1 to 5 stars). This info is used to compute the proper tip.
 * [x] **Optional**: **Settings**
  1. User can enter Local Tax (%)
  2. User can decide whether or not to calculate the tip Before or After the taxes have been applied
  3. User can decide whether she wants to get a Total Value rounded (either to the next Int above or below)
  4. User can decide whether or not to let the app calculate the tip based on her input or use user-predefined values (%). Depending of this decision (using a switch) some elements of the UI will be disabled or enabled.
 * [x] **Optional**: User can enter the number of person spliting the bill to get "per person" values
 * [x] **Optional**: The App uses custom segues from a custom Class "CustomSegue" created adhoc
 * [x] **Optional**: The App uses NSDate to reset the values used the last time after a period of time set to 10 min
 * [x] **Optional**: The App uses NSLocale to gather information suchs as currency symbols and thousands separatos
 * [x] **Optional**: Segment controls have been customized with images
 * [x] **Optional**: The app includes custom icons for different devices and a loading page
 
 * [x] **Optional**: **>>>>>>>>>>>>>>>   Secret Game   <<<<<<<<<<<<<<<<<**
Users can access a Secret Game by Shaking the device while in the results page. A button inviting to participate will appear. 
The idea would be to challenge friendly servers that deliver an outstanding Quality of Service Tip Boost to play the game for a potential Tip Boost of 5% in the bill.
The aim of the game is to shake the device at least 50 times in 10 secongs to get the prize. If the user wins, a Congratulations Badge will be displayed on the screen toghether with the updates values for Total, Tip Rate and Tip Value.

During the game the SecretGameButton bounces around the screen. The movement of the button is generated randomly using **UIKit Dynamics** elements suchs as **UIDynamicAnimator**, **UIGravityBehavior** and **UICollisionBehavior**.

The shake-counter uses data (**CMAccelerometerData**) from the device accelerometer to detect changes in the direction of the acceleration in the 3-axis (x, y, z). Everytime a "shake" (change of sign in the acceleration vector) is detected, the **ShakeCounter** is updated

--------------------------

##Walkthrough of all user stories:



GIF created with [LiceCap](http://www.cockos.com/licecap/).


(*) Includes time reading classes and framework references such as UIKit Dynamics Catalog, UIStoryboardsegue. Also some time learning about the Xcode Developper Tool "Instruments", as well as understanding diferences between Objective-C and Swift in terms of memory management (e.g. ARC)
(**) The app does not use a Navigation Controller and handle the transitions between VC manually
