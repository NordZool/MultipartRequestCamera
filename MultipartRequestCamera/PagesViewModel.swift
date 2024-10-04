//
//  PagesViewModel.swift
//  MultipartRequestCamera
//
//  Created by nikita on 4.10.24.
//

import Combine

class PagesViewModel {
    //MARK: - Public properties
    let pagesTypeSubject: CurrentValueSubject<[PageType],Never> = .init([])
    
    //MARK: - Private properties
    private let pagesNetworkService: PagesNetworkService = .init()
    
    //MARK: - Public methods
    func uploadNewPage() {
        let lastPageType = pagesTypeSubject.value.last
        //-1 когда еще ни одной страницы нету в pagesTypeSubject
        let pageIndex = lastPageType?.page ?? -1
        let totalPages = lastPageType?.totalPages ?? -1
        
        if pageIndex != totalPages - 1 {
            pagesNetworkService.getPageType(with: String(pageIndex + 1)) { [weak self] result in
                switch result {
                case .success(let pageType):
                    self?.pagesTypeSubject.value.append(pageType)
                case .failure(let failure):
                    print(failure)
                }
            }
        }
    }
}
