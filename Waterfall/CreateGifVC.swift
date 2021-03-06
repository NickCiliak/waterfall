//
//  CreateGifVC.swift
//  Waterfall
//
//  Created by lsecrease on 3/26/16.
//  Copyright © 2016 Nick Ciliak. All rights reserved.
//

import UIKit
import ImageIO
import MobileCoreServices
import AVFoundation
import CameraManager



class CreateGifVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: - Constants
    
    let cameraManager = CameraManager()
    
      // the frames collection view
    @IBOutlet weak var frameCollectionView: UICollectionView!
    

    var cell:UICollectionViewCell!
    
    // the selected index of the elements/properties/options collection view
    var collectionViewIndex = 2
    
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
    
    // the gif array content
    var gifArray:[Dictionary<String,Any>] = [["text": "", "font": "Bebas", "fontColor": UIColor.whiteColor(), "backgroundColor": UIColor(red: 93.0/255.0, green: 156.0/255.0, blue: 236.0/255.0, alpha: 1.0), "image": UIImage(named: "frame")]]
    
    
    // an alert view (used to show the user a wait for message while creating the gif)
    var alert: UIAlertView?
    
    //Camera Stuff
    //Image Placeholder
    var stillImage:UIImage?
    var preview: AVCaptureVideoPreviewLayer?
    
    var status: Status = .Preview
    @IBOutlet weak var cameraPreview: UIView!
    
    var frameCell: FrameCollectionViewCell!

    
    // set the status bar to light
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraManager.showAccessPermissionPopupAutomatically = false
        
        let currentCameraState = cameraManager.currentCameraStatus()
        
       

    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
       cameraManager.resumeCaptureSession()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.stopCaptureSession()
    }
    
    private func addCameraToView()
    {
        
        cameraManager.addPreviewLayerToView(cameraPreview, newCameraOutputMode: CameraOutputMode.VideoWithMic)
        cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage: String) -> Void in
            
            let alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in  }))
            
            self?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    

    
    @IBAction func deleteImageClicked(sender: AnyObject) {
        // reset the array by giving it a default frame value
        gifArray = [["text": "", "font": "Bebas", "fontColor": UIColor.whiteColor(), "backgroundColor": UIColor(red: 93.0/255.0, green: 156.0/255.0, blue: 236.0/255.0, alpha: 1.0), "image": UIImage()]]
        
        // reload the data on the two collection views
        frameCollectionView.reloadData()
       
        
     
        
    }
    
  


    
    //Camera Capture
    @IBAction func capture(sender: UIButton) {
        
        switch (cameraManager.cameraOutputMode) {
        case .StillImage:
            cameraManager.capturePictureWithCompletition({ (image, error) -> Void in
                self.gifArray[self.currentFrame]["image"] = image;
                print("Image Saved & current frame")
                print(self.currentFrame)
                self.nextFrameCard()
                self.frameCollectionView.reloadData()
            })
            
        case .VideoWithMic, .VideoOnly:
            sender.selected = !sender.selected
            sender.setTitle(" ", forState: UIControlState.Selected)
            sender.backgroundColor = sender.selected ? UIColor.redColor() : UIColor.greenColor()
    
        }
    }
    
    func nextFrameCard() {
        //initializeCamera()
        self.gifArray.append(["text": "", "font": "Bebas", "fontColor": UIColor.whiteColor(), "backgroundColor": UIColor(red: 93.0/255.0, green: 156.0/255.0, blue: 236.0/255.0, alpha: 1.0), "image": UIImage(named: "frame")])
        //self.imageView.image = image;
        //self.collectionView.reloadData()
        
        // scroll the index collection view to the selected frame
        self.frameCollectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: self.gifArray.count - 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        
        // set the new current frame
        self.currentFrame = self.gifArray.count - 1
    }
    
    
 
    
    // delegate method called when any collection view ended the scrolling animation
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        // call the another event as sometimes is not called
        scrollViewDidEndDecelerating(scrollView)
    }
    
    // delegate method called when any collection view ended the scrolling deceleration
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // if the scroll view received is the frames collection view
        if scrollView == frameCollectionView {
            // get the new current frame
            currentFrame = Int(frameCollectionView.contentOffset.x / frameCollectionView.frame.size.width)

            // set the new main textfield text
            //mainTextField.text = gifArray[currentFrame]["text"] as? String
            
            // if we are in the process of creating a gif
            if creatingGif {
                // call the gif creator function as this means it already did the last frame (if it existed)
                recursiveGifCreator()
            }
        }
    }

    
    // MARK: Collection View Delegates and Data Source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    // collection view method -> number of items in section (we only use one section)
    internal func collectionView(collectionView: UICollectionView, numberOfItemsInSection section:Int)->Int {
        
        
        // else return 0 as default
        return gifArray.count
    }
    
    // collection view method -> cell for item at index path (where all the cells are populated)
    internal func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // declare a cell
       
        let cell:UICollectionViewCell!
       

        if collectionView == frameCollectionView {
            // load the gif cell template
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("GifCell", forIndexPath: indexPath)

            
            // if image is not nil
            if gifArray[indexPath.row]["image"] != nil {
                // set the background image
                //cell.imageView.image = gifArray[indexPath.row]["image"] as? UIImage
                (cell.contentView.viewWithTag(7) as! UIImageView).image = gifArray[indexPath.row]["image"] as? UIImage
            }
//
            
            // if we are in the process of creating a gif
            if creatingGif {
                // add corner radius to each cell
                cell.layer.cornerRadius = 24
                // hide the info label
                //(cell.contentView.viewWithTag(10) as! UILabel).hidden = true
            }
                // if we are not
            else {
                // set the corner radius to 0
                cell.layer.cornerRadius = 0
            }

            
        }
            // if not a correct index
        else {
            // load a default cell
            
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        }
        
        // return the cell
        return cell 
        
    }
    
//    // collection view method -> size for item at index path (where all the cells are given a size)
   internal func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    // if this is the frames collection view
    if collectionView == frameCollectionView {
    // set a width that is equal to the collection view width. Set a height that is a equal to the collection view height
    return CGSizeMake(collectionView.bounds.width, collectionView.bounds.height)
    }
  
    // else set a default
    else {
    // return a default size
    return CGSizeZero
    }

    }
    
    
    // collection view method -> cell selected at index path
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // if this is the frames collection view
       if collectionView == frameCollectionView {
            // set the current label text to the main textfield
            //mainTextField.text = gifArray[currentFrame]["text"] as? String
            // show the keyboard and the textfield
            //mainTextField.becomeFirstResponder()
        }
            // if this is the indexs collection view
        
        
    }
    




    
    
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
        alert.show();
        
        // set the creating gif variable to true to indicate we are starting the process
        creatingGif = true
        
        // set the current index to 0 as we are starting
        currentIndex = 0
        
        // create the file properties (we make the gif to loop)
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]
        
        // create a file url for the gif
        fileURL = NSURL(fileURLWithPath: getDocumentsDirectory() as String, isDirectory: true).URLByAppendingPathComponent("animated\(Int(arc4random_uniform(UInt32(10000000)))).gif")
        
        // create a destination needed for the process
        destination = CGImageDestinationCreateWithURL(fileURL as CFURLRef, kUTTypeGIF, gifArray.count, nil)!
        // set its properties
        CGImageDestinationSetProperties(destination!, fileProperties as CFDictionaryRef)
        
        // reload the data so we have corner radius and no info labels
        frameCollectionView.reloadData()
        frameCollectionView.layoutIfNeeded()
        
        // if we are on the first frame, start the creation
        if currentFrame == currentIndex {
            recursiveGifCreator()
        }
            // if not scroll to the beginning
        else {
            frameCollectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: currentIndex, inSection: 0), atScrollPosition:UICollectionViewScrollPosition.CenteredHorizontally, animated:true)
        }
    }
    
    // recursively create all the frames for the gif
    func recursiveGifCreator() {
        if currentIndex < gifArray.count {
            // call the create image function in order to create an snapshot of the current frame
            let image:UIImage = createImage(currentIndex)
            
            // add the image to the gif
            CGImageDestinationAddImage(destination!, image.CGImage!, frameProperties as CFDictionaryRef);
            
            // increase the current index
            currentIndex = currentIndex + 1
            
            // if this was the last one
            if currentIndex == gifArray.count {
                // finalize the process
                if (CGImageDestinationFinalize(destination!)) {
                    // if success, send the image to the share controller
                    let documentURL = NSURL(string: "\(fileURL)")
                    
                    // set the process to false
                    creatingGif = false
                    
                    // reload the data to see the correct data again
                    frameCollectionView.reloadData()
                    
                    
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
                frameCollectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: currentIndex, inSection: 0), atScrollPosition:UICollectionViewScrollPosition.CenteredHorizontally, animated:true)
            }
        }
    }
    
    // function to create a snapshot from the current frame
    func createImage(index:Int) -> UIImage {
        // get the current frame
        let auxView = frameCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
        
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
            
            // set the gif and the video
            viewController.gif = self.gifURL
            viewController.video = self.videoURL
        }
    }



}
