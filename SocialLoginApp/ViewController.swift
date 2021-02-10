//
//  ViewController.swift
//  SocialLoginApp
//
//  Created by Gianmarco Cotellessa on 06/02/21.
//

import UIKit
import SnapKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController {
    
    private lazy var container: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var facebookButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitle("Log in with Facebook", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(facebookLoginButtonClicked), for: .touchUpInside)
        return button
    }()
    
    private lazy var googleButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitle("Log in with Google", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(googleLoginButtonClicked), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        
        if let token = AccessToken.current, !token.isExpired {
            let token = token.tokenString
            facebookUserInfo(with: token)
        } else {
            makeUI()
        }
    }
    
    private func makeUI() {
        
        view.addSubview(facebookButton)
        facebookButton.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview().offset(100)
            maker.left.equalToSuperview().offset(22)
            maker.right.equalToSuperview().offset(-22)
            maker.height.equalTo(50)
        }
        
        view.addSubview(googleButton)
        googleButton.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview().offset(160)
            maker.left.equalToSuperview().offset(20)
            maker.right.equalToSuperview().offset(-20)
            maker.height.equalTo(50)
        }

    }

}

extension ViewController {
    
    @objc func facebookLoginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
            if let token = result?.token?.tokenString {
                self.facebookUserInfo(with: token)
                let controller = HomeViewController()
//                controller.modalPresentationStyle = .fullScreen
//                self.present(controller, animated: true)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func facebookUserInfo(with token: String) {
        let request = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                 parameters: ["fields":"email, name"],
                                                 tokenString: token,
                                                 version: nil,
                                                 httpMethod: .get)
        
        request.start { (connection, result, error) in
            if let r = result {
                print("User info object: \(r)")
            } else if let e = error {
                print("Error: \(e)")
            }
        }
    }
    
}

extension ViewController: GIDSignInDelegate {
    
    @objc func googleLoginButtonClicked() {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error {
            print("Failed to log into Google: ", err)
            return
        }
        if let googleUser = user {
            print("Successfully logged into Google", googleUser)
        }
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        let credential = Firebase.GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        FirebaseAuth.Auth.auth().signIn(with: credential) { (user, error) in
            if let err = error {
                print("Failed to create a Firebase User with Google account: ", err)
                return
            }
            guard let uid = user?.user.uid else { return }
            print("Successfully logged into Firebase with Google", uid)
            
            let controller = HomeViewController()
//            controller.modalPresentationStyle = .fullScreen
//            self.present(controller, animated: true)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}
