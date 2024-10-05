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
    private let pagesViewModel: PagesViewModel
    private let photoViewModel: PhotoViewModel
    private var cancellable: Set<AnyCancellable> = .init()
    
    //MARK: - Inits
    init(
        pagesViewModel: PagesViewModel,
        photoViewModel: PhotoViewModel) {
            self.pagesViewModel = pagesViewModel
            self.photoViewModel = photoViewModel
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
        registerCells()
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
        pagesViewModel.pagesTypeSubject
            .receive(on: DispatchQueue.main)
            .sink {[weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellable)
    }
    
    func registerCells() {
        tableView.register(PageTableViewCell.self, forCellReuseIdentifier: PageTableViewCell.identifier)
    }
    
    func presentPhotoPicker() {
        let photoPicker = PhotoPickerViewController()
        photoPicker.delegate = self
        self.present(photoPicker, animated: true)
    }
}

//MARK: - UITableViewDataSource
extension PagesTableViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        pagesViewModel.pagesTypeSubject.value.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pagesViewModel.pagesTypeSubject
            .value[section]
            .content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: PageTableViewCell.identifier,
            for: indexPath) as! PageTableViewCell
        
        let pageContent = pagesViewModel.pagesTypeSubject
            .value[indexPath.section]
            .content[indexPath.row]
        cell.configure(
            with: pagesViewModel,
            pageContent: pageContent)
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension PagesTableViewController : UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yPosition = scrollView.contentOffset.y
        let scrollViewHeight = scrollView.bounds.size.height
        if yPosition > tableView.contentSize.height - scrollViewHeight - paginationOffset {
            pagesViewModel.uploadNewPage()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let pageNumber = pagesViewModel.pagesTypeSubject
            .value[section]
            .page
        let headerTitle = "Номер страницы: \(pageNumber)"
        
        return headerTitle
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        photoViewModel.authorizedCameraAccess {[weak self] in
            let pageId = self?.pagesViewModel.pagesTypeSubject
                .value[indexPath.section]
                .content[indexPath.row]
                .id
            self?.photoViewModel.pageID = pageId
            DispatchQueue.main.async {
                self?.presentPhotoPicker()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension PagesTableViewController :
    UIImagePickerControllerDelegate &
    UINavigationControllerDelegate {
        
    
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            
            guard let image = info[.originalImage] as? UIImage else {
                return
            }
            photoViewModel.imageSubject.send(image)
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                   picker.dismiss(animated: true)
           }
}
