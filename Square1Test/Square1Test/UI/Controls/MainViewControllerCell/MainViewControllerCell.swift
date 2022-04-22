//
//  MainViewControllerCell.swift
//  Square1Test
//
//  Created by Serg Mykhailov on 22.04.2022.
//

import Foundation
import UIKit

class MainViewControllerCell: UICollectionViewCell {

    // MARK: - Public methods and properties

    public func configure(withModel model: Model) {
        titleLabel.text = model.title
    }

    // MARK: - Overridden methods

    override func prepareForReuse() {
        titleLabel.text = "Loading..."
    }

    // MARK: - Outlets

    @IBOutlet private var titleLabel: UILabel!

}

extension MainViewControllerCell {
    public class Model {
        public let title: String

        public init(withTitle title: String) {
            self.title = title
        }
    }
}
