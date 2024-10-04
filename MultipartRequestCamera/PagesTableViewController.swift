//
//  PagesTableViewController.swift
//  MultipartRequestCamera
//
//  Created by nikita on 4.10.24.
//

import UIKit

class PagesTableViewController : UIViewController {
    //MARK: - Subviews
    lazy var tableView = {
        let table = UITableView()
        table.delaysContentTouches = false
        table.backgroundColor = .blue
        
        return table
    }()
    //MARK: - Live cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        updateTableViewLayout(with: view.bounds.size)
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
            coordinator.animate(alongsideTransition: { (contex) in
                self.updateTableViewLayout(with: size)
            }, completion: nil)
        }
    
    //MARK: - Public methods
    func updateTableViewLayout(with size:CGSize) {
        self.tableView.frame = CGRect.init(origin: .zero, size: size)
    }
}
