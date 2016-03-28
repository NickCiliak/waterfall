//
//  ShareViewController.swift
//  Waterfall
//
//  Created by lsecrease on 3/27/16.
//  Copyright © 2016 Nick Ciliak. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    
    // the controller delegated of the share actions
    var shareController:UIDocumentInteractionController!
    
    // the video
    var video:NSURL?
    
    // the gif
    var gif:NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // init the share controller
        initShare()
    }

    
    // Share implementation
    func initShare() {
        shareController = UIDocumentInteractionController()
        shareController.delegate = self
    }
    
    // share controller delegate functions
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController{
        return self
    }
    
    // go back to menu
    @IBAction func backToMenu(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // share the gif
    @IBAction func shareGif(sender: AnyObject) {
        // pass it to our document interaction controller
        self.shareController.URL = gif;
        
        self.shareController.presentPreviewAnimated(true)
    }
    
    // share the video
    @IBAction func shareVideo(sender: AnyObject) {
        // pass it to our document interaction controller
        self.shareController.URL = video;
        
        self.shareController.presentPreviewAnimated(true)
    }
    
    // set the status bar to light
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    
    

  

}
