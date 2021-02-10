//
//  Button+Extension.swift
//  SocialLoginApp
//
//  Created by Gianmarco Cotellessa on 10/02/21.
//

import Foundation
import UIKit

extension UIButton {
   func press(completion:@escaping ((Bool) -> Void)) {
            UIView.animate(withDuration: 0.05, animations: {
                self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9) }, completion: { (finish: Bool) in
                    UIView.animate(withDuration: 0.1, animations: {
                        self.transform = CGAffineTransform.identity
                        completion(finish)
                    })
            })
    }
}
