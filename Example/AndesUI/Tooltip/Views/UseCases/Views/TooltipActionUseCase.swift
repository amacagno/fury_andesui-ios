//
//  TooltipActionUseCase.swift
//  AndesUI-demoapp
//
//  Created by Juan Andres Vasquez Ferrer on 10-02-21.
//  Copyright © 2021 MercadoLibre. All rights reserved.
//

import Foundation
import AndesUI

enum TooltipActionType: CaseIterable {
    case loud
    case quiet
    case transparent
    case link
}

class TooltipActionUseCase: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var typeDropdown: AndesDropdown!

    weak var dataSource: TooltipActionUseCaseDataSource? {
        didSet {
            self.reloadData()
        }
    }

    weak var delegate: TooltipActionUseCaseDelegate?

    private var actionTypes: [TooltipActionType] = []

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupNib()
        setupEvents()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupNib()
        setupEvents()
    }

    private func setupNib() {
        let className = String(describing: type(of: self))
        let nib = UINib(nibName: className, bundle: nil)

        guard let nibView = nib.instantiate(withOwner: self, options: nil)[0] as? UIView else {
            return
        }

        addSubview(nibView)
        nibView.translatesAutoresizingMaskIntoConstraints = false
        nibView.pinTo(view: self)
    }

    private func setupEvents() {
        self.titleTextField.addTarget(self, action: #selector(self.titleDidChange(_:)), for: .editingChanged)
    }

    @objc func titleDidChange(_ textField: UITextField) {
        self.delegate?.tooltipCase(self, updateInfo: textField.text)
    }

    private func reloadData() {
        self.actionTypes = dataSource?.supportTypes() ?? []
        let actionTitle = dataSource?.titleForType()

        let data = actionTypes.map { AndesDropDownMenuCell(title: "\($0)") }
        typeDropdown.delegate = self
        typeDropdown.triggerType = FormDropdownTrigger(title: "Style", placeholder: nil, helperText: nil)
        typeDropdown.menuType = DropdownBottomSheetMenu(rows: data)

        self.titleLabel.text = "Set info of \(actionTitle ?? "")"
    }
}

extension TooltipActionUseCase: AndesDropdownDelegate {
    func didSelectRowAt(indexPath: IndexPath) {
        let action = self.actionTypes[indexPath.row]
        self.delegate?.tooltipCase(self, didSelectCase: action)
    }
}
