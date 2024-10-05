//
//  PageTableViewCell.swift
//  MultipartRequestCamera
//
//  Created by nikita on 4.10.24.
//

import UIKit

class PageTableViewCell : UITableViewCell {
    lazy private var photoImage: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    //MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        autolayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Live cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImage.image = nil
    }
    
    //MARK: - Public methods
    func configure(
        with viewModel: PagesViewModel,
        pageContent: PageContent) {
            viewModel.loadImage(for: pageContent) { image in
                DispatchQueue.main.async { [weak self] in
                    self?.photoImage.image = image
                }
            }
    }
    
    //MARK: - Public methods
    private func autolayoutConstraints() {
        contentView.addSubview(photoImage)
        
        NSLayoutConstraint.activate([
            photoImage.heightAnchor.constraint(equalToConstant: 100),
            photoImage.widthAnchor.constraint(equalToConstant: 100),
            photoImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            photoImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            photoImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 20)
        ])
    }
}
