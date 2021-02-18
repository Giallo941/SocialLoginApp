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

class HomeViewController: BaseViewController {
    
    var user: User?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HomeViewCell.self, forCellReuseIdentifier: HomeViewCell.identifier)
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: CGFloat.leastNormalMagnitude)))
        tableView.tableFooterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: CGFloat.leastNormalMagnitude)))
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutAction))
        
        makeUI()
    }
    
    @objc func logoutAction() {
        if let type = user?.userType {
            self.showPopUp(title: "Log Out",
                           message: "Are you sure to exit from your \(type == .google ? "Google" : "Facebook") account ?",
                           confirmAction: {
                            switch type {
                            case .google:
                                GIDSignIn.sharedInstance().signOut()
                            case .facebook:
                                LoginManager().logOut()
                            }
                            self.navigationController?.popViewController(animated: true)
                           }) {}
        }
    }

//    override func willMove(toParent parent: UIViewController?) {
//        if parent == nil {
//            GIDSignIn.sharedInstance().signOut()
//            let manager = LoginManager()
//            manager.logOut()
//        }
//    }
    
    private func makeUI() {
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.height.equalToSuperview()
            maker.width.equalToSuperview()
        }
        
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeViewCell.identifier) as! HomeViewCell
        switch indexPath.row {
            case 0:
                cell.cellLabel.text = user?.userType.description
            case 1:
                cell.cellLabel.text = user?.email
            case 2:
                cell.cellLabel.text = user?.name
            default:
                break
        }
        cell.makeUI()
        return cell
    }
    
}
