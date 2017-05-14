//
//  EditMessageViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 13/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import Eureka
import NVActivityIndicatorView

class EditMessageViewController: FormViewController, NVActivityIndicatorViewable {

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
        ListCheckRow<String>.defaultCellSetup = { cell, row in
            cell.tintColor = Color.main
        }
        
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
        if segue.identifier == "editPictureSegue" {
            let destination = segue.destination as! PictureViewController
            destination.doneType = .pop
            destination.mid = message.mid
        }
    }
    
    @IBAction func modifyMessage(_ sender: Any) {
        if messageTitle == nil {
            showAlert(title: NSLocalizedString("tip_name", comment: ""),
                      content: "Please input a post title.",
                      controller: self)
            return
        }
        
        var oids: [String] = []
        for section in selectionSections {
            if let oid = section.selectedRow()?.value {
                oids.append(oid)
            }
        }
        
        startAnimating()
        
        messageManager.modify(messageId,
                              title: messageTitle!,
                              introudction: introduction,
                              price: price,
                              oids: oids)
        { (success, tip) in
            self.stopAnimating()
            if (success) {
                self.navigationController?.popViewController(animated: true)
            } else {
                showAlert(title: NSLocalizedString("tip_name", comment: ""),
                          content: tip!,
                          controller: self)
            }
        }
    }
    
    // MARK: - Service
    private func loadForm() {
        category = dao.categoryDao.getByCid(message.cid)
        selections = dao.selectionDao.findEnableByCategory(category)
        
        // Set default value for title, price and introduction.
        messageTitle = message.title
        price = message.price
        introduction = message.introduction!
        
        // Init form.
        form
            +++ Section()
            
            <<< ButtonRow() { row in
                row.title = NSLocalizedString("message_edit_pictures", comment: "")
                row.presentationMode = .segueName(segueName: "editPictureSegue", onDismiss: nil)
            }
            
            <<< ButtonRow() { row in
                row.title = NSLocalizedString("message_close_title", comment: "")
                row.cellStyle = .value1
                row.cell.accessoryType = .disclosureIndicator
                row.cell.tintColor = Color.main
            }.onCellSelection({ (cell, row) in
                let alertController = UIAlertController(title: NSLocalizedString("message_close_title", comment: ""),
                                                        message: NSLocalizedString("message_close_content", comment: ""),
                                                        preferredStyle: .alert)
                let close = UIAlertAction(title: NSLocalizedString("yes_name", comment: ""),
                                          style: .destructive,
                                          handler:
                { (action) in
                    
                })
                let cancel = UIAlertAction(title: NSLocalizedString("cancel_name", comment: ""),
                                           style: .cancel,
                                           handler: nil)
                alertController.addAction(close)
                alertController.addAction(cancel)
                self.present(alertController, animated: true, completion: nil)
            })
            
            +++ Section(NSLocalizedString("message_basic_info", comment: ""))
            
            <<< TextRow() { row in
                row.title = NSLocalizedString("message_title", comment: "")
                row.value = message.title!
                row.placeholder = NSLocalizedString("message_title_placeholder", comment: "")
                }.onChange({ row in
                    self.messageTitle = row.value
                })
            
            <<< IntRow(){ row in
                row.title = NSLocalizedString("message_price", comment: "")
                row.value = message.price
                row.placeholder = "0"
                }.onChange({ row in
                    self.price = row.value ?? 0
                })
            
            <<< TextAreaRow() { row in
                row.value = message.introduction!
                row.placeholder = NSLocalizedString("message_introduction_placeholder", comment: "")
                }.onChange({ row in
                    self.introduction = row.value ?? ""
                })
        
        for selection in selections {
            let selectionSection = SelectableSection<ListCheckRow<String>>(selection.identifier!,
                                                                           selectionType: .singleSelection(enableDeselection: true))
            for option in dao.optionDao.findEnableBySelection(selection) {
                selectionSection <<< ListCheckRow<String>() { row in
                    row.tag = option.oid
                    row.title = option.identifier
                    row.selectableValue = option.oid
                }
                
            }
            form +++ selectionSection
            selectionSections.append(selectionSection)
            
            // Set selected option.
            for option in message.options {
                if let row: ListCheckRow<String> = selectionSection.rowBy(tag: option.oid!) {
                    row.didSelect()
                }
            }
        }
        
    }

}
