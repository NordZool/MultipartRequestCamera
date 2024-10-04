//
//  PagesTableViewController.swift
//  MultipartRequestCamera
//
//  Created by nikita on 4.10.24.
//

import UIKit
import Combine

class PagesTableViewController : UIViewController {
    //MARK: - Subviews
    lazy var tableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.delaysContentTouches = false
        table.dataSource = self
        table.delegate = self
        
        return table
    }()
    //MARK: - Public properties
    ///Determines `y` offset from the bottom of tableView.contentSize when should start pagination
    public var paginationOffset: CGFloat = 200
    
    //MARK: - Private properties
    private let viewModel: PagesViewModel
    private var cancellable: Set<AnyCancellable> = .init()
    
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
        subscribeToPageTypesUpdate()
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
    
    func subscribeToPageTypesUpdate() {
        viewModel.pagesTypeSubject
            .receive(on: DispatchQueue.main)
            .sink {[weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellable)
    }
}

//MARK: - UITableViewDataSource
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

//MARK:
extension PagesTableViewController : UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yPosition = scrollView.contentOffset.y
        let scrollViewHeight = scrollView.bounds.size.height
        if yPosition > tableView.contentSize.height - scrollViewHeight - paginationOffset {
            viewModel.uploadNewPage()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let pageNumber = viewModel.pagesTypeSubject
            .value[section]
            .page
        let headerTitle = "Номер страницы: \(pageNumber)"
        
        return headerTitle
    }
}
