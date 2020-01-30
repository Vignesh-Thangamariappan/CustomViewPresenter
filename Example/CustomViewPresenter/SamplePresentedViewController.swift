//
//  SamplePresentedViewController.swift
//  CustomViewPresenter_Example
//
//  Created by Vignesh on 16/01/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import CustomViewPresenter

class SamplePresentedViewController: UIViewController, CustomViewPresentable {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func didChangeToFullScreen() {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .blue
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
