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
    
    private lazy var facebookButton: FBLoginButton = {
        let button = FBLoginButton()
        button.delegate = self
        return button
    }()
    
    private lazy var googleButton: GIDSignInButton = {
        let button = GIDSignInButton()
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
        }
        
        view.addSubview(googleButton)
        googleButton.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview().offset(150)
            maker.left.equalToSuperview().offset(20)
            maker.right.equalToSuperview().offset(-20)
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

extension ViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let token = result?.token?.tokenString {
            facebookUserInfo(with: token)
            let controller = HomeViewController()
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    
}

extension ViewController: GIDSignInDelegate {
    
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
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
        }
    }
    
}
