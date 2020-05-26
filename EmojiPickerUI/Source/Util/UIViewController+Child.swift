//
//  UIViewController+Child.swift
//  EmojiPickerUI
//
//  Created by Guilherme Rambo on 10/05/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func install(_ child: UIViewController) {
        addChild(child)
        
        child.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(child.view)
        
        NSLayoutConstraint.activate([
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        child.didMove(toParent: self)
    }
    
}
