//
//  ChatViewController.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 29/01/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

class ChatViewController: EditingViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var receiver: User!
    let userManager = UserManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.setCustomBack()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        
        navigationItem.title = receiver.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        var height = UIScreen.main.bounds.height
        // Adapt the height for iPhone X.
        if UIDevice.current.isX() {
            height += 50
        }
        self.shownHeight = height - 45
    }

}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = indexPath.row % 2 == 0 ?  "senderIdentifier" : "receiverIdentifier"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ChatTableViewCell
        cell.fill(avatar: indexPath.row % 2 == 0 ? userManager.avatar : receiver.avatar, message: "新しいデザインになったMagic Mouse 2は完全な充電式なので、従来の電池はもう必要ありません。ボディが一段と軽くなり、内蔵バッテリーと継ぎ目のないボトムシェルによって可動部品が一段と少なくなり、底面のデザインも最適化されています。")
        return cell
    }
}

extension ChatViewController: UITableViewDelegate {
    
}
