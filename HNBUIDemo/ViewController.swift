//
//  ViewController.swift
//  HNBUIDemo
//
//  Created by Kenichi Fujita on 3/27/21.
//

import UIKit
import HNBUI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red

        let tabBar = TabBar()
        view.addSubview(tabBar)
    }


}

