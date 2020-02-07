//
//  ViewController.swift
//  CustomViewPresenter
//
//  Created by vignesh.mariappan@anywhere.co on 01/16/2020.
//  Copyright (c) 2020 vignesh.mariappan@anywhere.co. All rights reserved.
//

import UIKit
import CustomViewPresenter

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapButton(_ sender: UIButton) {
        
        let viewControllerToPresent = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "SampleViewController")
        let navController = UINavigationController(rootViewController: SampleTableViewController())
        navController.isNavigationBarHidden = true
        self.interactivelyPresent(navController, animated: true, onCompletion: nil, shouldBeMaximized: true)
    }

}

