//
//  MusicListCell.swift
//  Shazam
//
//  Created by Jhon Gomez on 7/27/22.
//

import Foundation
import UIKit

class MusicListCell: UITableViewCell {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var image: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return UIImageView()
    }()

    private lazy var contentStackView: UIStackView = {
        let content = UIStackView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.alignment = .center
        content.axis = .horizontal
        content.distribution = .equalSpacing
        content.spacing = 10
        content.addArrangedSubview(image)
        content.addArrangedSubview(label)
        content.isLayoutMarginsRelativeArrangement = true
        content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
        content.backgroundColor = .none
        content.clipsToBounds = true

        return content
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .none

        addSubview(view: contentStackView, with: [
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])

        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalToConstant: 80),
            image.widthAnchor.constraint(equalToConstant: 80)
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configure(with hit: Hits) {
        backgroundColor = .clear

        label.text = hit.track.title
        guard let imageUri = hit.track.images?.background, let url = URL(string: imageUri) else {
            return
        }

        image.load(url: url)
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
    }
}
