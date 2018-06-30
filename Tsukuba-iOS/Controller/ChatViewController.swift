//
//  ChatViewController.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 29/01/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit
import SwiftyJSON
import RxSwift
import RxKeyboard

enum ChatCellType {
    case none
    case time(Date)
    case plainTextSender(String)
    case plainTextReceiver(String, String)
    case pictureSending(UIImage)
    case pictureSender(String)
    case pictureReceiver(String, String)
}

class ChatCellModel {
    
    var type: ChatCellType = .none
    
    init(type: ChatCellType) {
        self.type = type
    }
    
}

class ChatViewController: UIViewController {
    
    private struct Const {
        static let toolBarHeight: CGFloat = 50.0
    }

    private lazy var imagePickerController: UIImagePickerController = {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.navigationBar.barTintColor = Color.main
        imagePickerController.navigationBar.tintColor = .white
        imagePickerController.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor : UIColor.white
        ]
        return imagePickerController
    }()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plainTextField: UITextField!
    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    
    var receiver: User!
    var models: [ChatCellModel] = []
    var lastCreateAt = Date(timeIntervalSince1970: 0)
    var room: Room?
    
    let appDelagate = UIApplication.shared.delegate as! AppDelegate
    var viewHeight: CGFloat!
    var keyboardShowing = false

    private let disposeBag = DisposeBag()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCustomBack()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        
        navigationItem.title = receiver.name

        room = DaoManager.shared.roomDao.getByReceiverId(receiver.uid)
        if let room = room {
            updateModels(DaoManager.shared.chatDao.findByRoom(room))
            ChatManager.shared.syncChat(room) { [weak self] (success, chats, message) in
                self?.updateModels(chats)
                // TODO: update new only.
                self?.tableView.reloadData()
                self?.gotoBottom(false)
            }
        }

        viewHeight = view.frame.size.height - UIApplication.shared.statusBarFrame.size.height - (navigationController?.navigationBar.frame.size.height)!
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNewChat),
                                               name: .didReceiveNewChat, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connecting),
                                               name: .webSocketConnecting, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connected),
                                               name: .didWebSocketConnected, object: nil)

        RxKeyboard.instance.visibleHeight.drive(onNext: { keyboardVisibleHeight in
            if keyboardVisibleHeight == 0 {
                self.keyboardShowing = false
                UIView.animate(withDuration: 0.2) {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: UIScreen.main.bounds.height)
                }
            } else {
                if self.keyboardShowing {
                    return
                }
                self.keyboardShowing = true
                
                let tableHeight = self.tableView.contentSize.height
                let hiddenHeight = self.viewHeight - Const.toolBarHeight - keyboardVisibleHeight
                
                UIView.animate(withDuration: 0.2) {
                    if tableHeight < hiddenHeight {
                        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - keyboardVisibleHeight)
                    } else {
                        self.view.frame = CGRect(x: 0, y: -keyboardVisibleHeight, width: self.view.frame.size.width, height: self.view.frame.size.height)
                        if tableHeight < self.viewHeight - Const.toolBarHeight {
                            self.tableView.frame = CGRect(x: self.tableView.frame.origin.x,
                                                          y: self.tableView.frame.origin.y + self.viewHeight - tableHeight - Const.toolBarHeight,
                                                          width: self.tableView.frame.size.width,
                                                          height: tableHeight)
                        }
                    }
                }
            }
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        appDelagate.isChatting = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let room = room {
            ChatManager.shared.clearUnread(room)
        }
        
        tabBarController?.tabBar.isHidden = false
        appDelagate.isChatting = false
    }
    
    private func insertChats(_ chats: [Chat]) {
        if (chats.count == 0) {
            return
        }
        let oldCount = models.count
        updateModels(chats)
        
        tableView.beginUpdates()
        var indexPaths: [IndexPath] = []
        for row in oldCount...(models.count - 1) {
            indexPaths.append(IndexPath(row: row, section: 0))
        }
        tableView.insertRows(at: indexPaths, with: .automatic)
        tableView.endUpdates()
        
        gotoBottom(true)
    }
    
    private func gotoBottom(_ animated: Bool) {
        if models.count > 0 {
            let indexPath = IndexPath(row: models.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    // MARK: Notification
    @objc func keyboardDidShow(notification: NSNotification) {
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
    }

    @objc func didReceiveNewChat(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        if let chats = userInfo["chats"] as? [Chat] {
            insertChats(chats.filter { (chat) -> Bool in
                guard let rid = chat.room?.rid, let room = room else {
                    return false
                }
                return room.rid == rid
            })
        }
    }
    
    @objc func connecting() {
        navigationItem.title = R.string.localizable.chats_loading()
    }
    
    @objc func connected() {
        navigationItem.title = receiver.name
    }
    
    // MARK: Action
    @IBAction func send(_ sender: Any) {
        let content = plainTextField.text!
        
        if content == "" {
            return
        }
        plainTextField.text = ""
        plainTextField.resignFirstResponder()
        ChatManager.shared.sendPlainText(receiver: receiver.uid, content: content) { [weak self] (success, chats, message) in
            self?.insertChats(chats)
        }
    }
    
    @IBAction func openCamara(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            present(imagePickerController, animated: true)
        }
    }
    
    @IBAction func openPhotoLibrary(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePickerController.sourceType = .photoLibrary
            present(imagePickerController, animated: true)
        }
    }
    
    // MARK: - Service
    private func updateModels(_ chats: [Chat]) {
        guard let room = room else {
            return
        }
        
        for chat in chats {
            guard let createAt = chat.createAt,
                let content = chat.content,
                let avatar = room.receiverAvatar else {
                continue
            }
            if lastCreateAt.isInSameDay(date: createAt) {
                if lastCreateAt.isInToday {
                    if createAt.timeIntervalSince(lastCreateAt) > 5 * 60 {
                        models.append(ChatCellModel(type: .time(createAt)))
                        lastCreateAt = createAt
                    }
                }
            } else {
                models.append(ChatCellModel(type: .time(createAt)))
                lastCreateAt = createAt
            }
            
            // Plain text.
            let isSender = room.creator ? chat.direction : !chat.direction
            var type: ChatCellType = .none
            switch chat.type {
            case ChatMessageType.plainText.rawValue:
                type = isSender ? .plainTextSender(content) : .plainTextReceiver(avatar, content)
            case ChatMessageType.picture.rawValue:
                type = isSender ? .pictureSender(content) : .pictureReceiver(avatar, content)
            default:
                break
            }
            models.append(ChatCellModel(type: type))

        }
    }
    
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        switch model.type {
        case .time(let time):
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatTimeIdentifier, for: indexPath)!
            cell.time = time
            return cell
        case .plainTextSender(let content):
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatSenderIdentifier, for: indexPath)!
            cell.fill(avatar: UserManager.shared.avatar, message: content)
            return cell
        case .plainTextReceiver(let avatar, let content):
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatReceiverIdentifier, for: indexPath)!
            cell.fill(avatar: avatar, message: content)
            return cell
        case .pictureSending(let pictureImage):
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.pictureSenderIdentifier, for: indexPath)!
            cell.avatar = UserManager.shared.avatar
            cell.pictureImage = pictureImage
            return cell
        
        case .pictureSender(let pictureUrl):
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.pictureSenderIdentifier, for: indexPath)!
            cell.avatar = UserManager.shared.avatar
            cell.picture = pictureUrl
            return cell
        case .pictureReceiver(let avatar, let pictureUrl):
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.pictureReceiverIdentifier, for: indexPath)!
            cell.avatar = avatar
            cell.picture = pictureUrl
            return cell
        case .none:
            return UITableViewCell()
        }

    }
    
}

extension ChatViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -20 {
            self.plainTextField.resignFirstResponder()
        }
    }
    
}

extension ChatViewController: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        
        picker.dismiss(animated: true, completion: nil)
        
        ChatManager.shared.sendPicture(receiver: receiver.uid, image: image, start: { compressedImage in
            if let image = compressedImage {
                self.models.append(ChatCellModel(type: .pictureSending(image)))
                self.tableView.reloadData()
                self.gotoBottom(true)
            }
        }, completion: { (success, chats, message) in
            
        })
    }
    
}

extension ChatViewController: UINavigationControllerDelegate {
    
}
