//
//  ChatToolBarBiew.swift
//  Tsukuba-iOS
//
//  Created by mon.ri on 2018/07/09.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit
import SnapKit

protocol ChatInputBarDelegate: class {
    func didOpenCamara()
    func didOpenPhotoLibrary()
    func didSendPlainText(_ text: String)
}

class ChatInputBarView: UIView {
    
    private struct Const {
        static let margin: CGFloat = 8
    }
    
    private lazy var cameraButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.image.send_picture_camera(), for: .normal)
        button.addTarget(self, action: #selector(openCamara), for: .touchUpInside)
        return button
    }()
    
    private lazy var photoLibraryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.image.send_picture_library(), for: .normal)
        button.addTarget(self, action: #selector(openPhotoLibrary), for: .touchUpInside)
        return button
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.image.send_text(), for: .normal)
        button.addTarget(self, action: #selector(sendPlainText), for: .touchUpInside)
        return button
    }()

    private lazy var plainTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .white
        textField.borderStyle = .none
        textField.layer.cornerRadius = 5
        textField.returnKeyType = .send
        textField.delegate = self
        return textField
    }()
    
    weak var delegate: ChatInputBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(cameraButton)
        addSubview(photoLibraryButton)
        addSubview(sendButton)
        addSubview(plainTextField)
        
        createConstratints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isFirstResponder: Bool {
        return plainTextField.isFirstResponder
    }
    
    @discardableResult override func resignFirstResponder() -> Bool {
        if plainTextField.isFirstResponder {
            return plainTextField.resignFirstResponder()
        }
        return false
    }
    
    private func createConstratints() {
        
        cameraButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(Const.margin)
            $0.top.equalToSuperview().offset(Const.margin)
            $0.bottom.equalToSuperview().offset(-Const.margin)
            $0.width.equalTo(cameraButton.snp.height).multipliedBy(1)
        }
        
        photoLibraryButton.snp.makeConstraints {
            $0.left.equalTo(cameraButton.snp.right).offset(Const.margin)
            $0.top.equalToSuperview().offset(Const.margin)
            $0.bottom.equalToSuperview().offset(-Const.margin)
            $0.width.equalTo(cameraButton.snp.height).multipliedBy(1)
        }
        
        sendButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-Const.margin)
            $0.top.equalToSuperview().offset(Const.margin)
            $0.bottom.equalToSuperview().offset(-Const.margin)
            $0.width.equalTo(cameraButton.snp.height).multipliedBy(1)
        }
        
        plainTextField.snp.makeConstraints {
            $0.left.equalTo(photoLibraryButton.snp.right).offset(Const.margin)
            $0.right.equalTo(sendButton.snp.left).offset(-Const.margin)
            $0.top.equalToSuperview().offset(Const.margin)
            $0.bottom.equalToSuperview().offset(-Const.margin)
        }
        
    }
    
    @objc private func openCamara() {
        delegate?.didOpenCamara()
    }
    
    @objc private func openPhotoLibrary() {
        delegate?.didOpenPhotoLibrary()
    }
    
    @objc private func sendPlainText() {
        guard let text = plainTextField.text else {
            return
        }
        if let delegate = delegate, text != "" {
            plainTextField.text = ""
            delegate.didSendPlainText(text)
        }
    }
    
}

extension ChatInputBarView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == plainTextField {
            sendPlainText()
        }
        return true
    }

}
