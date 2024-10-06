//
//  PageTableViewCell.swift
//  MultipartRequestCamera
//
//  Created by nikita on 4.10.24.
//

import UIKit

class PageTableViewCell : UITableViewCell {
    static let identifier: String = "PageTableViewCell"
    
    lazy private var photoImage: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.image = .placeholder
        
        return imageView
    }()
    
    lazy private var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.minimumScaleFactor = 0.8
        
        return label
    }()
    
    lazy private var subtitleLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .placeholderText
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.textAlignment = .left
        
        return label
    }()
    
    //MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = .init(top: 0, left: 10, bottom: 0, right: 10)
        autolayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Live cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImage.image = .placeholder
    }
    
    //MARK: - Public methods
    func configure(
        with viewModel: PagesViewModel,
        pageContent: PageContent) {
            viewModel.loadImage(for: pageContent) { image in
                DispatchQueue.main.async { [weak self] in
                    if let image = image {
                        self?.photoImage.image = image
                    }
                }
            }
            
            titleLabel.text = pageContent.name
            subtitleLabel.text = "id: \(pageContent.id)"
    }
    
    //MARK: - Public methods
    private func autolayoutConstraints() {
        contentView.addSubview(photoImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            //photoImage
            photoImage.heightAnchor.constraint(equalToConstant: 100),
            photoImage.widthAnchor.constraint(equalToConstant: 100),
            photoImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            photoImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10)
                .priority(.required - 1),
            photoImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
                .priority(.required - 1),
            
            //titleLabel
            titleLabel.topAnchor.constraint(equalTo: photoImage.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: photoImage.trailingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.heightAnchor.constraint(lessThanOrEqualTo:photoImage.heightAnchor, constant: -20),
            
            //subtitleLabel
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
}
