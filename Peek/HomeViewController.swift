//
//  HomeViewController.swift
//  Peek
//
//  Created by Naga Praveen Kumar Pendyala on 5/23/16.
//  Copyright © 2016 Peek. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let Width = view.frame.size.width
        
        username.frame = CGRectMake(16, 200, Width-32, 30)
        password.frame = CGRectMake(16, 240, Width-32, 30)
        loginBtn.center = CGPointMake(Width/2, 330)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func login(sender: AnyObject) {
        
        
        
        self.performSegueWithIdentifier("navigate", sender: self)
    }
    
    
}


