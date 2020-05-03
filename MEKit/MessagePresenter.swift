//
//  MessagePresenter.swift
//  MEKit
//
//  Created by Pablo Ezequiel Romero Giovannoni on 23/11/2019.
//  Copyright © 2019 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import Foundation
import UIKit

protocol MessagePresenter {
    func presentAlert(withError error: Error)
}

extension MessagePresenter where Self: UIViewController {
    func presentAlert(withError error: Error) {
        let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "OK",
                                     style: .cancel,
                                     handler: nil)
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
    }
}
