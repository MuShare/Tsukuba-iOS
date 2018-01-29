//
//  ChatViewController.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 29/01/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var receiver: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setCustomBack()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        
        navigationItem.title = receiver.name
    }

}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "receiverIdentifier", for: indexPath) as! ChatTableViewCell
        cell.fill(user: receiver, message: "新しいデザインになったMagic Mouse 2は完全な充電式なので、従来の電池はもう必要ありません。ボディが一段と軽くなり、内蔵バッテリーと継ぎ目のないボトムシェルによって可動部品が一段と少なくなり、底面のデザインも最適化されています。そのすべてが、Magic Mouse 2を一段とトラッキングしやすいマウスにしました。デスクの上で動かす時の抵抗も少なくなっています。マウスの表面はMulti-Touchに対応しているので、シンプルなジェスチャーでウェブページをスワイプしたり文書をスクロールしていくことができます。Magic Mouse 2は箱から出したらすぐに使うことができ、あなたのMacとのペアリングは自動で行えます。")
        return cell
    }
}

extension ChatViewController: UITableViewDelegate {
    
}
