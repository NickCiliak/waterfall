//
//  CaptureVC.swift
//  Waterfall
//
//  Created by lsecrease on 3/6/16.
//  Copyright © 2016 Nick Ciliak. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO
import MobileCoreServices

enum Status: Int {
    case Preview, Still, Error
}

class CaptureVC: UIViewController, XMCCameraDelegate, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var mainTextField: UITextField!
    
    //Image Placeholder
    var stillImage:UIImage?
    
    var preview: AVCaptureVideoPreviewLayer?
    
    var camera: XMCCamera?
    var status: Status = .Preview
    
    // the gif array content
    var gifArray:[Dictionary<String,Any>] = [["text": "", "font": "Bebas", "fontColor": UIColor.blackColor(), "backgroundColor": UIColor(red: 93.0/255.0, green: 156.0/255.0, blue: 236.0/255.0, alpha: 1.0), "image": UIImage()]]
    
    // the current frame index
    var currentFrame = 0
    
    // a boolean variable use to control if we are in the process of creating a gif
    var creatingGif = false
    
    // the current index of the the process of creating a gif
    var currentIndex = 0
    
    // the destination used on the process of creating a gif
    var destination:CGImageDestinationRef?
    
    // properties of the frames used on the process of creating a gif
    var frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 0.5]]
    
    // the file url used on the process of creating a gif
    var fileURL = NSURL()
    
    // the file url for the video used on the process of creating a gif
    var videoURL = NSURL()
    
    // the file url for the gif used on the process of creating a gif
    var gifURL = NSURL()
    

    
    // set the status bar to light
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }


    override func viewDidLoad() {
        super.viewDidLoad()
     self.initializeCamera()
        collectionView.delegate = self
        collectionView.reloadData()
    
        
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
        //self.cameraPreview.hidden = false
    }
    
    func establishVideoPreviewArea() {
        self.preview = AVCaptureVideoPreviewLayer(session: self.camera?.session)
        self.preview?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.preview?.frame = self.cameraPreview.bounds
        self.preview?.cornerRadius = 8.0
        self.cameraPreview.layer.addSublayer(self.preview!)
    }

    @IBAction func deleteImageClicked(sender: AnyObject) {
        
        //gifArray.removeAtIndex(currentFrame)
        initializeCamera()
        collectionView.reloadData()
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
                    self.gifArray[self.currentFrame]["image"] = image;
                    print("Image Saved")
                    self.nextFrameCard()
                    
                    
                    UIView.animateWithDuration(0.225, animations: { () -> Void in
                        //self.imageView.alpha = 1.0;
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
                    //self.gifArray[self.currentFrame]["image"] = nil
                    //self.imageView.image = nil;
                    self.status = .Preview
            })
        }
        print(gifArray.count)
        collectionView.reloadData()
        //mainTextField.becomeFirstResponder()

    }
    @IBAction func deleteGIF(sender: AnyObject) {
        gifArray.removeAll()
        self.cameraPreview.layer.addSublayer(self.preview!)
        collectionView.reloadData()
        initializeCamera()
    }
    
    func nextFrameCard() {
        //initializeCamera()
        self.gifArray.append(["text": "", "font": "Bebas", "fontColor": UIColor.whiteColor(), "backgroundColor": UIColor(red: 93.0/255.0, green: 156.0/255.0, blue: 236.0/255.0, alpha: 1.0), "image": UIImage()])
        //self.imageView.image = image;
        self.collectionView.reloadData()
        // scroll the index collection view to the selected frame
        self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: self.gifArray.count - 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        
        // set the new current frame
        self.currentFrame = self.gifArray.count - 1
    }
    
//    // event called when a the keyboard is going to show
   func keyboardWillShow (notification: NSNotification){
//        // get the info of the notification and get the keyboard height to move up the inputs view
     var info = notification.userInfo!
    let keyboardFrame:CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
//        
//        // set the new constant of the constraint and animate it
//        //mainTextFieldBottomConstraint.constant = keyboardFrame.height
 UIView.animateWithDuration(0.4) { () -> Void in
  self.view.layoutIfNeeded()
      }
 }
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

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifArray.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //let cell:UICollectionViewCell!
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("IndexCell", forIndexPath: indexPath)
        
        // if image is not nil
        if gifArray[indexPath.row]["image"] != nil {
            // set the background image
            (cell.contentView.viewWithTag(7) as! UIImageView).image = gifArray[indexPath.row]["image"] as? UIImage
        }
        
        return cell
    }
   
    
  

    
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



