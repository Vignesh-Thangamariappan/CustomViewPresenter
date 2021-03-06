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
    
    var heightForMiniMode: CGFloat? = 401
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func didChangeToFullScreen() {
//        let viewController = SampleTableViewController()
//        viewController.view.backgroundColor = .blue
//        self.navigationController?.isNavigationBarHidden = false
//        self.navigationController?.pushViewController(viewController, animated: true)
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

class SampleTableViewController: UITableViewController {
    var sections = 30
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if indexPath.row == 0 {
            let textField = UITextField(frame: cell.frame)
            textField.placeholder = "Certificate"
            cell.addSubview(textField)
            return cell
        }
        cell.textLabel?.text = "Section \(indexPath.row)"
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.endEditing(true)
        if indexPath.row == 3 {
            maximizeToFullScreen()
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [.init(style: .destructive, title: "Remove", handler: { (_, _) in
            print("REMOVE CELL \(indexPath.row)")
        })]
    }
    
    var heightForMiniMode: CGFloat? = 600
    var shouldExpandToMaxMode: Bool = false
}

extension SampleTableViewController: CustomViewPresentable {
    func didChangeToFullScreen() {
        print("I am in full screen")
    }
}
