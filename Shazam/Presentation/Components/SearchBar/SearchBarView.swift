//
//  SearchBarView.swift
//  Shazam
//
//  Created by Jhon Gomez on 7/25/22.
//

import Foundation
import Combine
import UIKit

protocol SearchBarDelegate: AnyObject {
    func didDataChange(data: [Hits]) ->  Void
}

class SearchBarView: UIStackView {
    // MARK: - NOTE: Instead of using a `delegate pattern we can just use a `Reactive-Programing` here
    weak var delegate: SearchBarDelegate? = nil

    /// Provider
    private let shazamProvider = ShazamProvider()

    /// Subscriptions
    private var subscriptions: Set<AnyCancellable> = []

    var recents: [String] {
        self.shazamProvider.recents
    }

    /// Loading Icon
    private lazy var loadingIcon: UIImageView = {
        let image = UIImage(systemName: "video.and.waveform")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    /// Search Bar
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .white
        textField.addTarget(self, action: #selector(searchValueDidChange), for: .editingChanged)
        textField.layer.cornerRadius = 7
        textField.alpha = 0.7
        textField.placeholder = "Artist, Songs & Albums"
        textField.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        return textField
    }()

    init() {
        super.init(frame: .zero)
        commonInit()

        shazamProvider.isLoading.sink(receiveValue: { state in
            self.animatedLoading(state)
        }).store(in: &subscriptions)

        shazamProvider.data
            .sink(receiveValue: { data in
            self.delegate?.didDataChange(data: data.tracks?.hits ?? [])
        }).store(in: &subscriptions)
    }

    private func animatedLoading(_ state: Bool) {
        UIView.animate(withDuration: TimeInterval(0.5),
                       delay: 0.0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 1,
                       options: [],
                       animations: {
                                self.loadingIcon.isHidden = state
                                self.searchTextField.alpha = state ? 0.2 : 0.7
                                self.layoutIfNeeded()
                            },
                       completion: nil)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        // Remove subscriptions
        subscriptions.removeAll()
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal
        distribution = .fill
        spacing = 10
        isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)

        addArrangedSubview(searchTextField)
        addArrangedSubview(loadingIcon)
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    /// Listen when textfield value change
    @objc private func searchValueDidChange() {
        guard let value = searchTextField.text else {
            return
        }

        shazamProvider.term.send(value)
    }
}
