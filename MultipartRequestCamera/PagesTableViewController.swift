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
        table.dataSource = self
        return table
    }()
    
    //MARK: - Private properties
    private let viewModel: PagesViewModel
    
    //MARK: - Inits
    init(viewModel: PagesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    //Дописать подписку на изменения pageTypes в VM.
}

extension PagesTableViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.pagesTypeSubject.value.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.pagesTypeSubject
            .value[section]
            .content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let pageContent = viewModel.pagesTypeSubject
            .value[indexPath.section]
            .content[indexPath.row]
        
        var config = cell.defaultContentConfiguration()
        config.text = "id: \(pageContent.id) , name: \(pageContent.name)"
        cell.contentConfiguration = config
        
        return cell
    }
}
