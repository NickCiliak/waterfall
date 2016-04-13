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

class CaptureVC: UIViewController, XMCCameraDelegate, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet var keyboardInputAccessory: UIView!
    @IBOutlet weak var keyboardTextField: UITextField!

    
    //Image Placeholder
    var stillImage:UIImage?
    
    var preview: AVCaptureVideoPreviewLayer?
    
    var camera: XMCCamera?
    var status: Status = .Preview
    
    // the gif array content
    var gifArray:[Dictionary<String,Any>] = [["text": "", "image": UIImage(named: "frame")]]
    
    // an alert view (used to show the user a wait for message while creating the gif)
    var alert: UIAlertView?
    
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
    
     var lastSelectedIndex: NSIndexPath?

    
    // set the status bar to light
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardTextField.inputAccessoryView = keyboardInputAccessory
        
        self.initializeCamera()
        collectionView.delegate = self
        collectionView.reloadData()
    
        
        keyboardTextField.becomeFirstResponder()
        keyboardTextField.delegate = self
        
        // add an observer to catch later when the keyboard will show
        // handle text view
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
       
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
                    print("Current Frame: \(self.currentFrame)")
                    print("Gif Array Count: \(self.gifArray.count)")
                    //self.keyboardTextField.becomeFirstResponder()
                    self.collectionView.reloadData()
                    
                  
                    
//                    // set the new current frame
//                    self.currentFrame = self.gifArray.count 
//                    print("New Current frame: \(self.currentFrame) ")
//                    self.nextFrameCard()
                    //self.collectionView.reloadData()
                    
                    
                    
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
        self.gifArray.append(["image": UIImage(named: "frame")])
        //self.imageView.image = image;
        //self.collectionView.reloadData()
        
        // scroll the index collection view to the selected frame
        self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: self.gifArray.count - 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: true)
        
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
       //mainTextFieldBottomConstraint.constant = keyboardFrame.height
 UIView.animateWithDuration(0.4) { () -> Void in
  self.view.layoutIfNeeded()
      }
 }
    
    // touches began on the main view, deal with the focuses of the textfields
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchesSet = touches as NSSet
        let touch = touchesSet.anyObject() as? UITouch
        
        // if we were editing the main textfield and we lose the focus
        if keyboardTextField.isFirstResponder() && touch!.view != self.keyboardTextField //&& touch!.view != self.frameCollectionView
        {
            // dismiss the keyboard
            keyboardTextField.resignFirstResponder();
            
            // set the new constraints
            //mainTextFieldBottomConstraint.constant = -50
            //UIView.animateWithDuration(0.2) { () -> Void in
                //self.view.layoutIfNeeded()
            }
       }
    
    // event called when the return button is tapped on the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        // set the new constant of the constraint and animate it
        //mainTextFieldBottomConstraint.constant = -50
        UIView.animateWithDuration(0.2) { () -> Void in
            self.view.layoutIfNeeded()
        }
        
        return true
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifArray.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //let cell:UICollectionViewCell!
       // let cell = collectionView.dequeueReusableCellWithReuseIdentifier("IndexCell", forIndexPath: indexPath)
        
        // if image is not nil
        //if gifArray[indexPath.row]["image"] != nil {
            // set the background image
         //   (cell.contentView.viewWithTag(7) as! UIImageView).image = gifArray[indexPath.row]["image"] as? UIImage
       // }
       // else {
         //   (cell.contentView.viewWithTag(7) as! UIImageView).image = UIImage(named: "bg")
        //}
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("IndexCell", forIndexPath: indexPath) as! FrameCollectionViewCell
        cell.imageView.image = gifArray[indexPath.row]["image"] as? UIImage
        cell.mainTextLabel.text = gifArray[indexPath.row]["text"] as? String
        return cell
    }
    // collection view method -> cell selected at index path
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
       keyboardTextField.text = gifArray[currentFrame]["text"] as? String
        // show the keyboard and the textfield
        keyboardTextField.becomeFirstResponder()
        
        //let cell = collectionView.dequeueReusableCellWithReuseIdentifier("IndexCell", forIndexPath: indexPath) as! FrameCollectionViewCell
        //cell.mainTextField.text = gifArray[currentFrame]["text"] as? String
        // show the keyboard and the textfield
        //cell.mainTextField.becomeFirstResponder()
    }
    
   
    // delegate method called when any collection view ended the scrolling animation
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        // call the another event as sometimes is not called
        scrollViewDidEndDecelerating(scrollView)
    }
    
    // delegate method called when any collection view ended the scrolling deceleration
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // if the scroll view received is the frames collection view
        if scrollView == collectionView {
            // get the new current frame
            
            //currentFrame = Int(collectionView.contentOffset.y / collectionView.frame.size.height)
            

            
            // set the new main textfield text
            //mainTextField.text = gifArray[currentFrame]["text"] as? String
            
            // scroll the index collection view to the selected frame
            //indexCollectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: currentFrame, inSection: 0), atScrollPosition:UICollectionViewScrollPosition.CenteredHorizontally, animated:true)
            
            // if we are in the process of creating a gif
            if creatingGif {
                // call the gif creator function as this means it already did the last frame (if it existed)
                recursiveGifCreator()
            }
        }
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
    
 

    
//All the GIF creation stuff
    
    // event called when the create gif button is tapped
    @IBAction func createImage() {
        // call to create the image
        createGIF()
       
    }
    // create GIF function (prepares all the settings)
    func createGIF() {
        // create an alert
        let alert = UIAlertView(title: "Creating the GIF", message: "Please wait...", delegate: nil, cancelButtonTitle: nil);
        
        // add a loading indicator
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(50, 10, 37, 37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        loadingIndicator.startAnimating();
        
        alert.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        
        // show the alert view
       //alert.show();
        
        // set the creating gif variable to true to indicate we are starting the process
        creatingGif = true
        
        if creatingGif == true {
            print("Creating Gif is true")
        }
        
        // set the current index to 0 as we are starting
       currentIndex = 0
        
//        if currentIndex == 0 {
//            print("Current Index set to 0")
//        }
        
        
        
        // create the file properties (we make the gif to loop)
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]
        
        
        // create a file url for the gif
        fileURL = NSURL(fileURLWithPath: getDocumentsDirectory() as String, isDirectory: true).URLByAppendingPathComponent("animated\(Int(arc4random_uniform(UInt32(10000000)))).gif")
        
        
        // create a destination needed for the process
        destination = CGImageDestinationCreateWithURL(fileURL as CFURLRef, kUTTypeGIF, gifArray.count, nil)!
        // set its properties
        CGImageDestinationSetProperties(destination!, fileProperties as CFDictionaryRef)
        
        // reload the data so we have corner radius and no info labels
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
        // if we are on the first frame, start the creation
        if currentFrame == currentIndex {
            recursiveGifCreator()
            print("recursiveGif function called")
        }
            // if not scroll to the beginning
        else {
            collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: currentIndex, inSection: 0), atScrollPosition:UICollectionViewScrollPosition.Top, animated:true)
            print("This was called")
            print("Current Index ",currentIndex)
            print("current frame ", currentFrame)
           
        }
    }
    
    // recursively create all the frames for the gif
    func recursiveGifCreator() {
        if currentIndex < gifArray.count {
            print("current index is less that the count of gifArray")
            // call the create image function in order to create an snapshot of the current frame
            let image:UIImage = createImage(currentIndex)
            
            // add the image to the gif
            CGImageDestinationAddImage(destination!, image.CGImage!, frameProperties as CFDictionaryRef);
            
            // increase the current index
            currentIndex = currentIndex + 1
            
            // if this was the last one
            if currentIndex == gifArray.count {
                 print("current index is equal that the count of gifArray")
                // finalize the process
                if (CGImageDestinationFinalize(destination!)) {
                    // if success, send the image to the share controller
                    let documentURL = NSURL(string: "\(fileURL)")
                    
                    // set the process to false
                    creatingGif = false
                    
                    // reload the data to see the correct data again
                    collectionView.reloadData()
                    
                    
                    // completion handler called when the video is finished
                    let completionHandler:kGIF2MP4ConversionCompleted = { (path:ImplicitlyUnwrappedOptional<String>, error:ImplicitlyUnwrappedOptional<NSError>) in
                        // if error, print it and stop it here
                        if  error != nil {
                            print(error)
                        }
                            // else, share it
                        else {
                            // create the URL
                            let documentURL = NSURL(string: "\(path)")
                            
                            // store on the video variable
                            self.videoURL = documentURL!
                            
                            // get back to main thread
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                // perform the segue
                                self.performSegueWithIdentifier("ShareSegue", sender: self)
                                print("Segue being performed-Cross fingers")
                            }
                        }
                    };
                    
                    // create an URL for the video
                    let vfileURL = NSURL(fileURLWithPath: getDocumentsDirectory() as String, isDirectory: true).URLByAppendingPathComponent("animated\(Int(arc4random_uniform(UInt32(10000000)))).mp4")
                    // create an URL for the thumbnail
                    let tfileURL = NSURL(fileURLWithPath: getDocumentsDirectory() as String, isDirectory: true).URLByAppendingPathComponent("animated\(Int(arc4random_uniform(UInt32(10000000)))).jpg")
                    
                    // store the gif url to share it later
                    gifURL = documentURL!
                    
                    // create a new GIFDownloader class
                    let gifD = GIFDownloader()
                    
                    // process the gif into a video
                    gifD.processGIFData(NSData(contentsOfURL: documentURL!),
                        toFilePath: vfileURL,
                        thumbFilePath: tfileURL.absoluteString,
                        completed: completionHandler)
                    
                    // dismiss the loading alert
                    self.alert?.dismissWithClickedButtonIndex(-1, animated: true)
                }
            }
                // if not the last, then continue
            else {
                // scroll to the next frame
                collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: currentIndex, inSection: 0), atScrollPosition:UICollectionViewScrollPosition.Top, animated:true)
                print("It must not be the last frame..")
            }
        }
    }
    
    // function to create a snapshot from the current frame
    func createImage(index:Int) -> UIImage {
        
        print("createImage called somewhere")
        // get the current frame
        let auxView = collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
        
        // get the bounds of the view we want to create a image of
        let screenshotBounds = CGSizeMake(auxView!.bounds.width, auxView!.bounds.height)
        
        // threshold max size
        let maxSize = Double(1280.0);
        
        // check the max dimension
        let maxDim = Double(max(auxView!.bounds.width, auxView!.bounds.height));
        
        // get the scale
        let scale = CGFloat(Double(maxSize / maxDim));
        
        // begin to create the image
        UIGraphicsBeginImageContextWithOptions(screenshotBounds, false, scale);
        
        // render in the view we want
        auxView!.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        // create and render the image
        let screenCapture = UIGraphicsGetImageFromCurrentImageContext();
        
        // finalize the creation
        UIGraphicsEndImageContext();
        
        // return the snapshot
        return screenCapture
    }
    
    // aux function used to get the correct path to store an image
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShareSegue" {
            // Get the new view controller using segue.destinationViewController.
            // Pass the selected object to the new view controller.
            let viewController = segue.destinationViewController as! ShareViewController
            //self.alert?.dismissWithClickedButtonIndex(<#T##buttonIndex: Int##Int#>, animated: <#T##Bool#>)
            // set the gif and the video
            viewController.gif = self.gifURL
            viewController.video = self.videoURL
        }
    }



}



