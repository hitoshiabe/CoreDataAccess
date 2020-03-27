//
//  ViewController.swift
//  Precure
//
//  Created by Hitoshi Abe on 2020/03/27.
//  Copyright © 2020 Hitoshi Abe. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var repository: PrecureRepository!

    private var joinedPrecures = [Precure]()

    override func viewDidLoad() {
        super.viewDidLoad()

        repository = PrecureRepositoryImpl()
        repository.delegate = self
    }

    @IBAction func syncButtonTapped(_ sender: UIButton) {
        try? repository.sync()
    }

    @IBAction func countButtonTapped(_ sender: UIButton) {
        do {
            let precureSeriesCount = try repository.precureSeriesCount()
            let precureCount = try repository.precureCount()
            presentOkAlert("シリーズ数 : \(precureSeriesCount)\nプリキュア数 : \(precureCount)")
        } catch {}
    }

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        try? repository.allDelete()
        presentOkAlert("削除完了")
    }
}

extension ViewController: PrecureRepositoryDelegate {

    func didChangePrecure(_ precure: Precure, result: PrecureDidChangeResult) {
        switch result {
        case .joined:
            joinedPrecures.append(precure)
            presentPrecureAlertSafety()
        default:
            break
        }
    }

    private func presentPrecureAlertSafety() {
        guard joinedPrecures.count == 1 else { return }

        let alert = UIAlertController(title: "\(joinedPrecures[0].precureName)参戦", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { [weak self] (_) in
            guard let self = self else { return }
            self.joinedPrecures.remove(at: 0)
            self.presentPrecureAlertSafety()
        })
        let skipAction = UIAlertAction(title: "スキップ", style: .cancel, handler: { [weak self] (_) in
            guard let self = self else { return }
            self.joinedPrecures.removeAll()
        })
        alert.addAction(okAction)
        alert.addAction(skipAction)
        present(alert, animated: true, completion: nil)
    }
}

private extension UIViewController {

    func presentOkAlert(_ message: String, okHandler handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: handler)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
