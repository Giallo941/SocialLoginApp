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

class ViewController: BaseViewController {
    
    private lazy var loader = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    
    private func makeUI() {
        
        loader.center = view.center
        loader.style = .large
        loader.color = .gray
        view.addSubview(loader)
        
        view.addSubview(googleButton)
        googleButton.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview().offset(160)
            maker.left.equalToSuperview().offset(20)
            maker.right.equalToSuperview().offset(-20)
            maker.height.equalTo(50)
        }
        
        view.addSubview(facebookButton)
        facebookButton.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview().offset(100)
            maker.left.equalToSuperview().offset(22)
            maker.right.equalToSuperview().offset(-22)
            maker.height.equalTo(50)
        }
        
        googleButton.isHidden = true
        facebookButton.isHidden = true
    }
    
    private func setupUI() {
        loader.isHidden = false
        loader.startAnimating()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        
        if let accessToken = AccessToken.current, !accessToken.isExpired {
            let token = accessToken.tokenString
            facebookUserInfo(with: token, completion: { user in
                let controller = HomeViewController()
                controller.user = user
                self.navigationController?.pushViewController(controller, animated: true)
            })
        } else {
            if(GIDSignIn.sharedInstance().hasPreviousSignIn()) {
                GIDSignIn.sharedInstance()?.restorePreviousSignIn()
            } else {
                loader.isHidden = true
                googleButton.isHidden = false
                facebookButton.isHidden = false
            }
        }
    }
    
}


extension ViewController: GIDSignInDelegate {
    
    @objc func googleLoginButtonClicked() {
        googleButton.press { finished in
            GIDSignIn.sharedInstance()?.signIn()
        }
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
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let err = error {
                print("Failed to create a Firebase User with Google account: ", err)
                return
            }
            guard let uid = user?.user.uid else { return }
            print("Successfully logged into Firebase with Google", uid)
            
            let controller = HomeViewController()
            if let email = user?.user.email, let name = user?.user.displayName {
                controller.user = User(userType: .google, email: email, name: name)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

extension ViewController {
    
    @objc func facebookLoginButtonClicked() {
        facebookButton.press { finished in
            let loginManager = LoginManager()
            loginManager.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
                if let token = result?.token?.tokenString {
                    self.facebookUserInfo(with: token, completion: { user in
                        let controller = HomeViewController()
                        controller.user = user
                        self.navigationController?.pushViewController(controller, animated: true)
                    })
                }
            }
        }
    }
    
    func facebookUserInfo(with token: String, completion: @escaping (User) -> Void) {
        let request = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                 parameters: ["fields":"email, name"],
                                                 tokenString: token,
                                                 version: nil,
                                                 httpMethod: .get)
        
        request.start { (connection, result, error) in
            if let r = result {
                print("User info object: \(r)")
                if let resultDictionary = r as? [String : String] {
                    if let email = resultDictionary["email"] {
                        if let name = resultDictionary["name"] {
                            let user = User(userType: .facebook,
                                            email: email,
                                            name: name)
                            completion(user)
                        }
                    }
                }
            } else if let e = error {
                print("Error: \(e)")
            }
        }
    }
    
}
