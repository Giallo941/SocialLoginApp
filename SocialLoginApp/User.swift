//
//  User.swift
//  SocialLoginApp
//
//  Created by Gianmarco Cotellessa on 17/02/21.
//

import Foundation

enum UserType {
    
    case google, facebook
    
    var description: String {
        switch self {
            case .google:
                return "Google Account"
            case .facebook:
                return "Facebook Account"
        }
    }
}

struct User {
    let userType: UserType
    let email: String
    let name: String
}
