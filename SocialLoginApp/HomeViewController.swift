//
//  HomeViewController.swift
//  SocialLoginApp
//
//  Created by Gianmarco Cotellessa on 07/02/21.
//

import UIKit
import SnapKit
import GoogleSignIn
import FBSDKLoginKit

class HomeViewController: UIViewController {
    
    var user: User?
    
    private var emailLabel = UILabel()
    private var nameLabel = UILabel()
    private var accountLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        emailLabel.text = user?.email
        nameLabel.text = user?.name
        accountLabel.text = user?.userType.description
        
        makeUI()
    }

    override func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            GIDSignIn.sharedInstance().signOut()
            let manager = LoginManager()
            manager.logOut()
        }
    }
    
    private func makeUI() {
        
        view.addSubview(accountLabel)
        accountLabel.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview().offset(-60)
        }
        
        view.addSubview(emailLabel)
        emailLabel.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(accountLabel.snp.bottom).offset(20.0)
        }
        
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(emailLabel.snp.bottom).offset(20.0)
        }
    }

}
