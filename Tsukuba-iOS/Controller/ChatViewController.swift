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
import AXPhotoViewer
import ESPullToRefresh

enum ChatCellType {
    case none
    case time(Date)
    case plainTextSender(String)
    case plainTextReceiver(String, String)
    case pictureSending(Int, UIImage)
    case pictureSender(Int, String, CGSize)
    case pictureReceiver(Int, String, String, CGSize)
}

enum ChatInsertPosition {
    case first
    case last
}

class ChatCellModel {
    
    var type: ChatCellType = .none
    
    init(type: ChatCellType) {
        self.type = type
    }
    
}

class ChatViewController: UIViewController {
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    private struct Const {
        static let toolBarHeight: CGFloat = 50.0
        static let pageSize = 10
        static let timeLabelSmallestInterval: TimeInterval = 5 * 60
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
    
    private var models: [ChatCellModel] = []
    private var firstCreateAt = Date(timeIntervalSince1970: 0)
    private var lastCreateAt = Date(timeIntervalSince1970: 0)
    private var smallestSeq = Int16.max
    private var room: Room?
    
    private var photos: [AXPhoto] = []
    
    private let appDelagate = UIApplication.shared.delegate as! AppDelegate
    private var viewHeight: CGFloat!
    private var keyboardShowing = false

    private let dao = DaoManager.shared
    private let disposeBag = DisposeBag()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCustomBack()
        navigationItem.title = receiver.name

        tableView.es.addPullToRefresh {
            guard let room = self.room else {
                return
            }

            self.insertRows(at: .first) { position in
                let chats = DaoManager.shared.chatDao.find(in: room, smallerThan: self.smallestSeq, pageSize: Const.pageSize)
                return self.updateModels(with: chats, at: position)
            }

            self.tableView.es.stopPullToRefresh()
        }

        room = DaoManager.shared.roomDao.getByReceiverId(receiver.uid)
        if let room = room {
            // Load the latest messages at first.
            let chats = DaoManager.shared.chatDao.find(in: room, pageSize: Const.pageSize)
            updateModels(with: chats, at: .last)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tableView.scrollToBottom(animated: false)
            }
            
            // Find all pictures for preview.
            for picture in dao.chatDao.find(by: ChatMessageType.picture.rawValue, in: room) {
                let time = dateFormatter.string(from: picture.createAt!)
                let photo = AXPhoto(attributedTitle: nil,
                                    attributedDescription: NSAttributedString(string: time),
                                    url: Config.shared.imageURL(picture.content!))
                photos.append(photo)
            }
            ChatManager.shared.syncChat(room) { [weak self] (success, chats, message) in
                if chats.count > 0 {
                    self?.insertChats(chats)
                }
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
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

        insertRows(at: .last) { position in
            updateModels(with: chats, at: position)
        }
    }
    
    private func insertRows(at position: ChatInsertPosition, after execution: ((ChatInsertPosition) -> Int)) {
        let updatedCount = execution(position)
        if updatedCount == 0 {
            return
        }
        
        tableView.beginUpdates()
        var indexPaths: [IndexPath] = []
        
        switch position {
        case .first:
            for row in 0...(updatedCount - 1) {
                indexPaths.append(IndexPath(row: row, section: 0))
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
            tableView.endUpdates()
        case .last:
            for row in (models.count - updatedCount)...(models.count - 1) {
                indexPaths.append(IndexPath(row: row, section: 0))
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
            tableView.endUpdates()
            tableView.scrollToBottom(animated: true)
        }
        
    }
    
    // MARK: Notification
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
        if let content = plainTextField.text, content != "" {
            plainTextField.text = ""
            plainTextField.resignFirstResponder()
            ChatManager.shared.sendPlainText(receiver: receiver.uid, content: content) { [weak self] (success, chat, message) in
                if let `self` = self, let chat = chat {
                    self.insertChats([chat])
                }
            }
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
    @discardableResult private func updateModels(with chats: [Chat], at postion: ChatInsertPosition) -> Int {
        guard let room = room else {
            return 0
        }
        
        if postion == .first {
            firstCreateAt = Date(timeIntervalSince1970: 0)
        }
        
        var insertModels: [ChatCellModel] = []
        for chat in chats {
            guard let createAt = chat.createAt,
                let content = chat.content,
                let avatar = room.receiverAvatar else {
                continue
            }

            // Plain text.
            let isSender = room.creator ? chat.direction : !chat.direction
            var type: ChatCellType = .none
            switch chat.type {
            case ChatMessageType.plainText.rawValue:
                type = isSender ? .plainTextSender(content) : .plainTextReceiver(avatar, content)
            case ChatMessageType.picture.rawValue:
                let size = CGSize(width: chat.pictureWidth, height: chat.pictureWidth)
                type = isSender ? .pictureSender(photos.count, content, size) : .pictureReceiver(photos.count, avatar, content, size)
                
            default:
                break
            }
            
            if let timeModel = timeModel(for: createAt, at: postion) {
                insertModels.append(timeModel)
            }
            insertModels.append(ChatCellModel(type: type))
            
            if chat.seq < smallestSeq {
                smallestSeq = chat.seq
            }
        }
        
        switch postion {
        case .first:
            // If the tiem of the last time label is closed to time of the fist time label in the existing models,
            // Remove the first time label in the existing models.
            if case let .time(time) = models[0].type {
                if time.timeIntervalSince(firstCreateAt) < Const.timeLabelSmallestInterval {
                    models.remove(at: 0)
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    tableView.endUpdates()
                }
            }
            models.insert(contentsOf: insertModels, at: 0)
        case .last:
            models.append(contentsOf: insertModels)
        }
        return insertModels.count
    }
    
    private func insertPictureSendingModel(image: UIImage) -> Int {
        var modelAdded = 1
        if let timeModel = timeModel(for: Date(), at: .last) {
            models.append(timeModel)
            modelAdded += 1
        }
        models.append(ChatCellModel(type: .pictureSending(photos.count, image)))
        photos.append(AXPhoto(attributedTitle: nil,
                              attributedDescription: NSAttributedString(string: dateFormatter.string(from: Date())),
                              image: image))
        return modelAdded
    }
    
    private func timeModel(for time: Date, at position: ChatInsertPosition) -> ChatCellModel? {
        var create = false
        switch position {
        case .first:
            if firstCreateAt.isInSameDay(date: time) {
                if time.timeIntervalSince(firstCreateAt) > Const.timeLabelSmallestInterval {
                    create = true
                    firstCreateAt = time
                }
            } else {
                create = true
                firstCreateAt = time
            }
        case .last:
            if lastCreateAt.isInSameDay(date: time) {
                if time.timeIntervalSince(lastCreateAt) > Const.timeLabelSmallestInterval {
                    create = true
                    lastCreateAt = time
                }
            } else {
                create = true
                lastCreateAt = time
            }
        }
        return create ? ChatCellModel(type: .time(time)) : nil
    }
    
}

extension ChatViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == plainTextField {
            send(sendButton)
        }
        return true
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
        case .pictureSending(let index, let pictureImage):
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.pictureSenderIdentifier, for: indexPath)!
            cell.fill(index: index, avatar: UserManager.shared.avatar, pictureImage: pictureImage, delegate: self)
            return cell
        case .pictureSender(let index, let pictureUrl, let size):
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.pictureSenderIdentifier, for: indexPath)!
            cell.fill(index: index, avatar: UserManager.shared.avatar, pictureUrl: pictureUrl, size: size, delegate: self)
            return cell
        case .pictureReceiver(let index, let avatar, let pictureUrl, let size):
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.pictureReceiverIdentifier, for: indexPath)!
            cell.fill(index: index, avatar: avatar, pictureUrl: pictureUrl, size: size, delegate: self)
            return cell
        case .none:
            return UITableViewCell()
        }

    }
    
}

extension ChatViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            if scrollView.contentOffset.y < -20 {
                self.plainTextField.resignFirstResponder()
            }
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
        
        var sendingCell: ChatPictureTableViewCell? = nil
        ChatManager.shared.sendPicture(receiver: receiver.uid, image: image, start: { [weak self] compressedImage in
            if let `self` = self, let image = compressedImage {
                self.insertRows(at: .last) { _ in
                    return self.insertPictureSendingModel(image: image)
                }
                if let cell = self.tableView.visibleCells.last as? ChatPictureTableViewCell {
                    cell.startLoading()
                    sendingCell = cell
                }
            }
        }, completion: { [weak self] (success, chat, message) in
            guard let `self` = self else {
                return
            }
            if !success {
                if let message = message {
                    self.showTip(message)
                }
                return
            }
            
            if let cell = sendingCell, let chat = chat {
                cell.stopLoading()
            }
        })
    }
    
}

extension ChatViewController: UINavigationControllerDelegate {
    
}

extension ChatViewController: ChatPictureTableViewCellDelegate {
    
    func didOpenPicturePreview(index: Int) {
        
        let dataSource = AXPhotosDataSource(photos: photos, initialPhotoIndex: index)
        let photosViewController = AXPhotosViewController(dataSource: dataSource)
        present(photosViewController, animated: true)
    }
    
}
