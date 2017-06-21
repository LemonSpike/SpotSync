//
//  LoginViewController.swift
//  Spot_Tutorial_Jared
//
//  Created by Ravi Kumar on 03/06/2017.
//  Copyright © 2017 Pranav Kasetti. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    var model = Model()
    
    @IBOutlet weak var bgImage: UIImageView!
    
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        
        if UIApplication.shared.openURL(model.loginUrl!) {
            if model.auth.canHandle(model.auth.redirectURL) {
                // To do - build in error handling
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        model.setup()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateAfterFirstLogin), name: NSNotification.Name("sessionStarted"), object: nil)
    }

    func updateAfterFirstLogin() {
        self.loginBtn.isHidden=true
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tbc: UITabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        (((tbc.viewControllers![0] as! UINavigationController).viewControllers[0]) as! ViewController).model=self.model
        ((tbc.viewControllers![1] as! UINavigationController).viewControllers.first as! TableViewController).model=self.model
        self.present(tbc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
