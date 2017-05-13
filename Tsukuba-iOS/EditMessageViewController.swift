//
//  EditMessageViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 13/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import Eureka

class EditMessageViewController: FormViewController {

    let dao = DaoManager.sharedInstance
    let messageManager = MessageManager.sharedInstance
    
    var messageId: String!
    var message: Message!
    
    var category: Category!
    var selections: [Selection]!
    
    var selectionSections: [SelectableSection<ListCheckRow<String>>]! = []
    var messageTitle: String?
    var price = 0
    var introduction = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCustomBack()
        self.view.tintColor = Color.main
        
        messageManager.detail(messageId) { (success, message) in
            if success {
                self.message = message!
                self.loadForm()
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - Service
    func loadForm() {
        category = dao.categoryDao.getByCid(message.cid)
        selections = dao.selectionDao.findEnableByCategory(category)
        
        form
            +++ Section(NSLocalizedString("message_basic_info", comment: ""))
            
            <<< TextRow() {
                $0.title = NSLocalizedString("message_title", comment: "")
                $0.value = message.title!
                $0.placeholder = NSLocalizedString("message_title_placeholder", comment: "")
                }.onChange({ (row) in
                    self.messageTitle = row.value
                })
            
            <<< IntRow(){
                $0.title = NSLocalizedString("message_price", comment: "")
                $0.value = message.price
                $0.placeholder = "0"
                }.onChange({ (row) in
                    self.price = row.value ?? 0
                })
            
            <<< TextAreaRow() {
                $0.value = message.introduction!
                $0.placeholder = NSLocalizedString("message_introduction_placeholder", comment: "")
                }.onChange({ (row) in
                    self.introduction = row.value ?? ""
                })
        
        for selection in selections {
            let selectionSection = SelectableSection<ListCheckRow<String>>(selection.identifier!,
                                                                           selectionType: .singleSelection(enableDeselection: true))
            for option in dao.optionDao.findEnableBySelection(selection) {
                let row = ListCheckRow<String>()
                row.title = option.identifier
                row.selectableValue = option.oid
                selectionSection.append(row)
            }
            form.append(selectionSection)
            selectionSections.append(selectionSection)
        }
    }

}
