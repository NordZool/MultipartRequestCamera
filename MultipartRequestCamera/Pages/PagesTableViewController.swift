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
        subscribeToAlertPresentation()
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
    
    func subscribeToAlertPresentation() {
        photoViewModel.showAlertSubject
            .receive(on: DispatchQueue.main)
            .sink {[weak self] alertType in
                switch alertType {
                case .cameraAccessError:
                    self?.presentGoToSettingAlert()
                case .failedPhotoUpload:
                    
                    self?.presentFailureUploadAlert()
                case .successPhotoUpload:
                    self?.presentSuccessUploadAlert()
                    
                default:
                    break
                }
            }
            .store(in: &cancellable)
    }
    
    func registerCells() {
        tableView.register(PageTableViewCell.self, forCellReuseIdentifier: PageTableViewCell.identifier)
    }
    
    func presentPhotoPicker() {
        if UIImagePickerController.isSourceTypeAvailable(.camera),
           let types = UIImagePickerController.availableMediaTypes(for: .camera),
           let imageType = types.first(where: {$0 == "public.image"}) {
        
            let photoPicker = UIImagePickerController()
            photoPicker.mediaTypes = [imageType]
            photoPicker.sourceType = .camera
            photoPicker.cameraFlashMode = .off
            photoPicker.cameraCaptureMode = .photo
            photoPicker.cameraDevice = .rear
            photoPicker.allowsEditing = false
            photoPicker.delegate = self
            
            self.present(photoPicker, animated: true)
        }
    }
    
    func presentGoToSettingAlert() {
        let alert = UIAlertController(
            title: String(localized:"No camera access"),
            message: String(localized:"Can change in settings"),
            preferredStyle: .alert)
        alert.addAction(.init(title: String(localized:"OK"), style: .cancel))
        alert.addAction(.init(title: String(localized:"Settings"), style: .default, handler: { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        }))
        
        self.present(alert, animated: true)
    }
    
    func presentSuccessUploadAlert() {
        let alert = UIAlertController(
            title: String(localized:"Success photo upload"),
            message: "",
            preferredStyle: .alert)
        alert.addAction(.init(title: String(localized:"OK"), style: .default))
        
        self.present(alert, animated: true)
    }
    
    func presentFailureUploadAlert() {
        let alert = UIAlertController(
            title: String(localized: "Failure photo upload"),
            message: "",
            preferredStyle: .alert)
        alert.addAction(.init(title: String(localized:"OK"), style: .default))
        
        self.present(alert,animated: true)
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
    ///Pagination
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
        let headerTitle = "\(String(localized:"Page Number")): \(pageNumber)"
        
        return headerTitle
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        photoViewModel.authorizedCameraAccess {[weak self] in
            let pageId = self?.pagesViewModel.pageID(for: indexPath)
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
                photoViewModel.showAlertSubject.send(.failedPhotoUpload)
                return
            }
            photoViewModel.imageSubject.send(image)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                   picker.dismiss(animated: true)
           }
}
