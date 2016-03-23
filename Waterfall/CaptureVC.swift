//
//  CaptureVC.swift
//  Waterfall
//
//  Created by lsecrease on 3/6/16.
//  Copyright © 2016 Nick Ciliak. All rights reserved.
//

import UIKit
import AVFoundation

enum Status: Int {
    case Preview, Still, Error
}

class CaptureVC: UIViewController, XMCCameraDelegate, UITextFieldDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var cameraPreview: UIView!
    
    @IBOutlet weak var mainTextField: UITextField!
    
    //Image Placeholder
    var stillImage:UIImage?
    
    var preview: AVCaptureVideoPreviewLayer?
    
    var camera: XMCCamera?
    var status: Status = .Preview
    
    // set the status bar to light
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }


    override func viewDidLoad() {
        super.viewDidLoad()
     self.initializeCamera()
        
        // add an observer to catch later when the keyboard will show
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.establishVideoPreviewArea()
    }
    
    func initializeCamera() {
        //self.cameraStatus.text = "Starting Camera"
        self.camera = XMCCamera(sender: self)
    }
    
    func establishVideoPreviewArea() {
        self.preview = AVCaptureVideoPreviewLayer(session: self.camera?.session)
        self.preview?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.preview?.frame = self.cameraPreview.bounds
        self.preview?.cornerRadius = 8.0
        self.cameraPreview.layer.addSublayer(self.preview!)
    }

    @IBAction func deleteImageClicked(sender: AnyObject) {
        initializeCamera()
    }
    
    @IBAction func capture(sender: AnyObject) {
        if self.status == .Preview {
            //self.cameraStatus.text = "Capturing Photo"
            UIView.animateWithDuration(0.225, animations: { () -> Void in
                self.cameraPreview.alpha = 0.0;
                //self.cameraStatus.alpha = 1.0
            })
            
            self.camera?.captureStillImage({ (image) -> Void in
                if image != nil {
                    self.imageView.image = image;
                    
                    UIView.animateWithDuration(0.225, animations: { () -> Void in
                        self.imageView.alpha = 1.0;
                        //self.cameraStatus.alpha = 0.0;
                    })
                    self.status = .Still
                } else {
                    //self.cameraStatus.text = "Uh oh! Something went wrong. Try it again."
                    self.status = .Error
                }
                
                //self.cameraCapture.setTitle("Reset", forState: UIControlState.Normal)
            })
        } else if self.status == .Still || self.status == .Error {
            UIView.animateWithDuration(0.225, animations: { () -> Void in
                //self.cameraStill.alpha = 0.0;
                //self.cameraStatus.alpha = 0.0;
                self.cameraPreview.alpha = 1.0;
                //self.cameraCapture.setTitle("Capture", forState: UIControlState.Normal)
                }, completion: { (done) -> Void in
                    self.imageView.image = nil;
                    self.status = .Preview
            })
        }
        
        mainTextField.becomeFirstResponder()

    }
    
//    // event called when a the keyboard is going to show
//    func keyboardWillShow (notification: NSNotification){
//        // get the info of the notification and get the keyboard height to move up the inputs view
//        var info = notification.userInfo!
//        let keyboardFrame:CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
//        
//        // set the new constant of the constraint and animate it
//        //mainTextFieldBottomConstraint.constant = keyboardFrame.height
//        UIView.animateWithDuration(0.4) { () -> Void in
//            self.view.layoutIfNeeded()
//        }
//    }
//    
//    // touches began on the main view, deal with the focuses of the textfields
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        let touchesSet = touches as NSSet
//        let touch = touchesSet.anyObject() as? UITouch
//        
//        // if we were editing the main textfield and we lose the focus
//        if mainTextField.isFirstResponder() && touch!.view != self.mainTextField //&& touch!.view != self.frameCollectionView  
//        {
//            // dismiss the keyboard
//            mainTextField.resignFirstResponder();
//            
//            // set the new constraints
//            //mainTextFieldBottomConstraint.constant = -50
//            //UIView.animateWithDuration(0.2) { () -> Void in
//                //self.view.layoutIfNeeded()
//            }
//       }
//    
//    // event called when the return button is tapped on the keyboard
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        
//        // set the new constant of the constraint and animate it
//        //mainTextFieldBottomConstraint.constant = -50
//        UIView.animateWithDuration(0.2) { () -> Void in
//            self.view.layoutIfNeeded()
//        }
//        
//        return true
//    }



   
    
  

    
    // MARK: Camera Delegate
    
    func cameraSessionConfigurationDidComplete() {
        self.camera?.startCamera()
    }
    
    func cameraSessionDidBegin() {
        //self.cameraStatus.text = ""
        UIView.animateWithDuration(0.225, animations: { () -> Void in
            //self.cameraStatus.alpha = 0.0
            self.cameraPreview.alpha = 1.0
            //self.cameraCapture.alpha = 1.0
            //self.cameraCaptureShadow.alpha = 0.4;
        })
    }
    
    func cameraSessionDidStop() {
        //self.cameraStatus.text = "Camera Stopped"
        UIView.animateWithDuration(0.225, animations: { () -> Void in
            //self.cameraStatus.alpha = 1.0
            self.cameraPreview.alpha = 0.0
        })
    }

}



