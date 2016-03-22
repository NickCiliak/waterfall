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

class CaptureVC: UIViewController, XMCCameraDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var cameraPreview: UIView!
    
    
    //Image Placeholder
    var stillImage:UIImage?
    
    var preview: AVCaptureVideoPreviewLayer?
    
    var camera: XMCCamera?
    var status: Status = .Preview


    override func viewDidLoad() {
        super.viewDidLoad()
     self.initializeCamera()
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
