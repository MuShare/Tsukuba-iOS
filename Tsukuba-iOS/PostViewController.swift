//
//  PostViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 07/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import Eureka

class PostViewController: FormViewController {

    let dao = DaoManager.sharedInstance
    let messgae = MessageManager.sharedInstance
    
    var category: Category!
    var selections: [Selection]!
    
    var selectionSections: [SelectableSection<ListCheckRow<String>>]! = []
    var messageTitle: String?
    var sell = true
    var price = 0
    var introduction = ""
    
    var mid: String!
    
    var navigationOptionsBackup : RowNavigationOptions?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCustomBack()
        
        selections = dao.selectionDao.findEnableByCategory(category)
        
        self.view.tintColor = Color.main
            
        navigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)
        navigationOptionsBackup = navigationOptions
        
        form
            +++ Section("Title & Type")
            
            <<< SegmentedRow<String>() {
                $0.title = "I want to"
                $0.options = ["sell", "buy"]
                $0.value = "sell"
            }.onChange({ (row) in
                self.sell = row.value! == "sell"
            })
            
            <<< TextRow() {
                $0.title = "Title"
                $0.placeholder = "Post title"
            }.onChange({ (row) in
                self.messageTitle = row.value
            })
        
            <<< IntRow(){
                $0.title = "Price"
                $0.placeholder = "0"
            }.onChange({ (row) in
                self.price = row.value ?? 0
            })
        
            <<< TextAreaRow() {
                $0.placeholder = "Introduction for this post."
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

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pictureSegue" {
            segue.destination.setValue(mid, forKey: "mid")
        }
    }
    
    // MARK: Action
    @IBAction func createMessage(_ sender: Any) {
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

        replaceBarButtonItemWithActivityIndicator(controller: self)
        
        messgae.create(title: messageTitle!,
                       introudction: introduction,
                       sell: sell,
                       price: price,
                       oids: oids,
                       cid: category.cid!,
                       success:
        { (mid) in
            self.mid = mid
            self.performSegue(withIdentifier: "pictureSegue", sender: self)
        }) {
            
        }

    }
}
