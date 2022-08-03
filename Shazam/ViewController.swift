//
//  ViewController.swift
//  Shazam
//
//  Created by Jhon Gomez on 7/25/22.
//

import UIKit

class ViewController: UIViewController {
    /// Search UIView.
    private lazy var searchBarView = SearchBarView()

    /// Used  to hold Shazam data
    var data = [Hits]()

    /// Search Label.
    private lazy var searchLabel: UILabel = {
        let label = UILabel()
        label.text = "Search"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 35.0)
        return label
    }()

    // TODO: Refactor move this declaration to another class definition
    /// Content to display the recents terms searched
    private lazy var contentRecents: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = #colorLiteral(red: 0.9679889083, green: 0.9679889083, blue: 0.9679889083, alpha: 1)
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 10
        stack.alignment = .leading
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        return stack
    }()

    // TODO: Refactor move this declaration to another class definition
    /// TableView to display the result from shazam
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(MusicListCell.self, forCellReuseIdentifier:  String(describing: MusicListCell.self))
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .none
        table.separatorStyle = .singleLine
        return table
    }()

    /// Holds which rows were animated
    var animatedRows = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(view: searchLabel, with: [
            searchLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor),
            searchLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
        ])

        view.addSubview(view: searchBarView, with: [
            searchBarView.widthAnchor.constraint(equalTo: view.widthAnchor),
            searchBarView.topAnchor.constraint(equalTo: searchLabel.bottomAnchor)
        ])

        view.addSubview(view: contentRecents, with: [
            contentRecents.topAnchor.constraint(equalTo: searchBarView.bottomAnchor),
            contentRecents.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        view.addSubview(view: tableView, with: [
            tableView.topAnchor.constraint(equalTo: contentRecents.bottomAnchor),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        tableView.delegate = self
        tableView.dataSource = self
        searchBarView.delegate = self
    }

    private func reloadRecentsTermsSearched() {
        UIView.animate(withDuration: 0.3) {
            self.contentRecents.subviews.forEach {
                $0.removeFromSuperview()
            }

            self.searchBarView.recents.forEach { item in
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.font = UIFont.systemFont(ofSize: 12.0)
                    label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                label.text = item
                    self.contentRecents.addArrangedSubview(label)
            }

            self.view.layoutIfNeeded()

        } completion: { _ in
        }
    }
}

// MARK: DataTable delegate

extension ViewController: UITableViewDelegate {}

// MARK: DataTable DataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hit = data[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MusicListCell.self), for: indexPath) as? MusicListCell else {
            return UITableViewCell()
        }

        cell.configure(with: hit)
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !animatedRows.contains(indexPath.row) else {
            return
        }

        animatedRows.append(indexPath.row)
        let rotation = CATransform3DTranslate(CATransform3DIdentity, -100, 150, 0)
        cell.layer.transform = rotation
        cell.alpha = 0

        UIView.animate(withDuration: 0.3  * Double(indexPath.row) ) {
            cell.alpha = 1
            cell.layer.transform = CATransform3DIdentity
        }
    }
}

// MARK: SearchView delegate

extension ViewController: SearchBarDelegate {
    func didDataChange(data: [Hits]) {
        self.animatedRows = []
        self.data = data
        self.reloadRecentsTermsSearched()
        self.tableView.reloadData()
    }
}
