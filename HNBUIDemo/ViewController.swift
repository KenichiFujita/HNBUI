//
//  ViewController.swift
//  HNBUIDemo
//
//  Created by Kenichi Fujita on 8/22/21.
//

import UIKit

class ViewController: UIViewController {

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    init(tabBarItemTitle: String, tabBarItemImage: UIImage?, backgroundColor: UIColor) {
        super.init(nibName: nil, bundle: nil)

        tabBarItem.title = tabBarItemTitle
        tabBarItem.image = tabBarItemImage
        tableView.backgroundColor = backgroundColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
    }

}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = String(indexPath.row)
        cell.backgroundColor = tableView.backgroundColor
        return cell
    }

}
