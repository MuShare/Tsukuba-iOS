//
//  PostViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 07/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import Eureka
import SwiftyJSON
import Alamofire

class PostViewController: FormViewController {

    let dao = DaoManager.sharedInstance
    var category: Category!
    var selections: [Selection]!
    
    var selectionSections: [SelectableSection<ListCheckRow<String>>]! = []
    var messageTitle: String?
    var sell = true
    var price = 0
    
    var mid: String!
    
    var navigationOptionsBackup : RowNavigationOptions?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selections = dao.selectionDao.findEnableByCategory(category)
        
        self.view.tintColor = RGB(0xf46d94)
            
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
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }.onChange({ (row) in
                self.messageTitle = row.value
            })
        
            <<< IntRow(){
                $0.title = "Price"
                $0.placeholder = "0"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }.onChange({ (row) in
                self.price = row.value ?? 0
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
    
        print(messageTitle!)
        print(sell)
        print(price)
        print(JSON(oids).rawString()!)

        let params: Parameters = [
            "cid": category.cid!,
            "title": messageTitle!,
            "oids": JSON(oids).rawString()!,
            "price": price,
            "sell": sell

        ]
        Alamofire.request(createUrl("api/message/create"),
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: tokenHeader())
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                self.mid = response.getResult()["mid"].stringValue
                print(self.mid)
            } else {
                
            }
        }
        

    }
}
