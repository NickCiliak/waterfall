//
//  ViewController.swift
//  Waterfall
//
//  Created by Nick Ciliak on 2/12/16.
//  Copyright (c) 2016 Nick Ciliak. All rights reserved.
//

import UIKit
import CameraManager

class ViewController: UIViewController {
    
    let cameraManager = CameraManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

  
    @IBAction func enableCameraButtonTapped(sender: AnyObject) {
        
         cameraManager.askUserForCameraPermissions({ permissionGranted in
            if permissionGranted {
                let vc: CreateGifVC? = self.storyboard?.instantiateViewControllerWithIdentifier("ImageVC") as? CreateGifVC
                if let validVC: CreateGifVC = vc {
                        self.navigationController?.pushViewController(validVC, animated: true)
                    
                }

            }
         })

    }


}

