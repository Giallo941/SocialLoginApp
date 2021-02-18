//
//  BaseViewController.swift
//  SocialLoginApp
//
//  Created by Gianmarco Cotellessa on 18/02/21.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }
    
    public func showPopUp(title: String,
                          message: String,
                          confirmAction: @escaping () -> (),
                          deniedAction: @escaping () -> ()) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Yes",
                                          style: .default,
                                          handler: { action in
                                            confirmAction()
                                          })
        
        let deniedAction = UIAlertAction(title: "No",
                                          style: .default,
                                          handler: { action in
                                            alert.dismiss(animated: true,
                                                          completion: nil)
                                          })
        
        alert.addAction(deniedAction)
        alert.addAction(confirmAction)
        
        self.present(alert, animated: true, completion: nil)
    }

}
