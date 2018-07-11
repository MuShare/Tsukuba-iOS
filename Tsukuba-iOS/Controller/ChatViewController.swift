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
    case pictureSending(UIImage)
    case pictureSender(String, CGSize)
    case pictureReceiver(String, String, CGSize)
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
        static let inputBarHeight: CGFloat = 50.0
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
    
    private lazy var inputBar: ChatInputBarView = {
        let barView = ChatInputBarView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Const.inputBarHeight))
        barView.delegate = self
        return barView
    }()

    @IBOutlet weak var tableView: UITableView!
    
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
    private var currentKeyboardHeight: CGFloat = 0
    private var enableToCloseKeyboard = true

    private let dao = DaoManager.shared
    private let currentUserAvarar = UserManager.shared.avatar
    private let disposeBag = DisposeBag()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var navStatusHeight: CGFloat {
        var height = UIApplication.shared.statusBarFrame.size.height
        if let navigation = navigationController {
            height += navigation.navigationBar.frame.size.height
        }
        return height
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCustomBack()
        navigationItem.title = receiver.name
        
        view.addSubview(inputBar)
        createConstraints()

        room = DaoManager.shared.roomDao.getByReceiverId(receiver.uid)
        if let room = room {
            // Load the latest messages at first.
            let chats = DaoManager.shared.chatDao.find(in: room, pageSize: Const.pageSize)
            updateModels(with: chats, at: .last)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tableView.scrollToBottom(animated: false)
            }
            
            // Find all pictures for preview.
            appendPreviewPictures(pictures: dao.chatDao.find(by: ChatMessageType.picture.rawValue, in: room))
            
            ChatManager.shared.syncChat(room) { [weak self] (success, chats, message) in
                if let `self` = self, chats.count > 0 {
                    self.insertChats(chats)
                }
            }
        }
        
        tableView.es.addPullToRefresh {
            guard let room = self.room else {
                self.tableView.es.stopPullToRefresh()
                return
            }
            
            let chats = DaoManager.shared.chatDao.find(in: room, smallerThan: self.smallestSeq, pageSize: Const.pageSize)
            self.insertRows(at: .first) { position in
                return self.updateModels(with: chats, at: position)
            }
            
            if chats.count == Const.pageSize || self.smallestSeq == 1 {
                self.tableView.es.stopPullToRefresh()
                return
            }
            
            // Load more chats from server.
            let seq = self.smallestSeq - Int16(Const.pageSize - 1)
            let pageSize = Const.pageSize - chats.count
            ChatManager.shared.syncChat(room, from: seq, with: pageSize) { [weak self] (success, chats, message) in
                guard let `self` = self else {
                    return
                }
                if success {
                    self.appendPreviewPictures(pictures: chats.filter {
                        $0.type == ChatMessageType.picture.rawValue
                    }, at: .first)
                    
                    self.insertRows(at: .first) { position in
                        return self.updateModels(with: chats, at: position)
                    }
                }
                self.tableView.es.stopPullToRefresh()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNewChat),
                                               name: .didReceiveNewChat, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connecting),
                                               name: .webSocketConnecting, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connected),
                                               name: .didWebSocketConnected, object: nil)

        RxKeyboard.instance.visibleHeight.drive(onNext: { keyboardVisibleHeight in
            if keyboardVisibleHeight == 0 {
                self.currentKeyboardHeight = 0
                UIView.animate(withDuration: 0.2) {
                    self.inputBar.snp.updateConstraints {
                        $0.bottom.equalToSuperview().offset(-self.bottomPadding)
                    }
                }
            } else {
                if keyboardVisibleHeight < self.currentKeyboardHeight {
                    return
                }
                self.currentKeyboardHeight = keyboardVisibleHeight
                
                UIView.animate(withDuration: 0.2) {
                    self.inputBar.snp.updateConstraints {
                        $0.bottom.equalToSuperview().offset(-self.bottomPadding - keyboardVisibleHeight)
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

        appDelagate.isChatting = true
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let room = room {
            ChatManager.shared.clearUnread(room)
        }

        appDelagate.isChatting = false
    }
    
    private func createConstraints() {
        
        inputBar.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-bottomPadding)
            $0.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview().offset(navStatusHeight)
            $0.bottom.equalTo(inputBar.snp.top)
        }
    }
    
    
    private func insertChats(_ chats: [Chat]) {
        if (chats.count > 0) {
            insertRows(at: .last) { position in
                updateModels(with: chats, at: position)
            }
            
            appendPreviewPictures(pictures: chats.filter {
                $0.type == ChatMessageType.picture.rawValue
            })
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
    
    // MARK: - Service
    @discardableResult private func updateModels(with chats: [Chat], at postion: ChatInsertPosition) -> Int {
        // Set room if there is no messages before.
        if room == nil {
            if chats.count > 0 {
                room = chats[0].room
            }
        }
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
                let size = CGSize(width: chat.pictureWidth, height: chat.pictureHeight)
                type = isSender ? .pictureSender(content, size) : .pictureReceiver(avatar, content, size)
                
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
        models.append(ChatCellModel(type: .pictureSending(image)))
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
    
    private func appendPreviewPictures(pictures: [Chat], at position: ChatInsertPosition = .last) {
        var sorted = pictures
        if position == .first {
            sorted.sort {
                $0.seq > $1.seq
            }
        }
        
        for picture in sorted {
            let time = dateFormatter.string(from: picture.createAt!)
            let photo = AXPhoto(attributedTitle: nil,
                                attributedDescription: NSAttributedString(string: time),
                                url: Config.shared.imageURL(picture.content!))
            switch position {
            case .first:
                photos.insert(photo, at: 0)
            case .last:
                photos.append(photo)
            }
        }
    }
    
}

extension ChatViewController: ChatInputBarDelegate {
    
    func didOpenCamara() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            present(imagePickerController, animated: true)
        }
    }
    
    func didOpenPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePickerController.sourceType = .photoLibrary
            present(imagePickerController, animated: true)
        }
    }
    
    func didSendPlainText(_ text: String) {
        ChatManager.shared.sendPlainText(receiver: receiver.uid, content: text) { [weak self] (success, chat, message) in
            if let `self` = self, let chat = chat {
                self.insertChats([chat])
            }
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
            cell.fill(with: .send, avatar: UserManager.shared.avatar, message: content)
            return cell
        case .plainTextReceiver(let avatar, let content):
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatReceiverIdentifier, for: indexPath)!
            cell.fill(with: .receive, avatar: avatar, message: content)
            return cell
        case .pictureSending(let pictureImage):
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.pictureSenderIdentifier, for: indexPath)!
            cell.fillSending(with: pictureImage, avatar: currentUserAvarar, delegate: self)
            return cell
        case .pictureSender(let pictureUrl, let size):
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.pictureSenderIdentifier, for: indexPath)!
            cell.fill(with: pictureUrl, size: size, avatar: currentUserAvarar, delegate: self)

            return cell
        case .pictureReceiver(let avatar, let pictureUrl, let size):
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.pictureReceiverIdentifier, for: indexPath)!
            cell.fill(with: pictureUrl, size: size, avatar: avatar, delegate: self)
            return cell
        case .none:
            return UITableViewCell()
        }

    }
    
}

extension ChatViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView && enableToCloseKeyboard && inputBar.isFirstResponder {
            if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 15  {
                enableToCloseKeyboard = false
                inputBar.resignFirstResponder()
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        enableToCloseKeyboard = true
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
                if let url = chat.content {
                    cell.sendingFinished(url: url)
                    
                    let time = self.dateFormatter.string(from: Date())
                    let photo = AXPhoto(attributedTitle: nil,
                                        attributedDescription: NSAttributedString(string: time),
                                        url: Config.shared.imageURL(url))
                    self.photos.append(photo)
                }
            }
        })
    }
    
}

extension ChatViewController: UINavigationControllerDelegate {
    
}

extension ChatViewController: ChatPictureTableViewCellDelegate {
    
    func didOpenPicturePreview(url: String) {
        let absoluteURL = Config.shared.createUrl(url)
        let index = photos.index { (photo) -> Bool in
            if let photoURL = photo.url, photoURL.absoluteString == absoluteURL {
                return true
            }
            return false
        }
        let dataSource = AXPhotosDataSource(photos: photos, initialPhotoIndex: index ?? 0)
        let photosViewController = AXPhotosViewController(dataSource: dataSource)
        present(photosViewController, animated: true)
    }
    
}
