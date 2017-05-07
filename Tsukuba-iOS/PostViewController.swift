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
    var category: Category!
    var selections: [Selection]!
    
    var navigationOptionsBackup : RowNavigationOptions?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selections = dao.selectionDao.findEnableByCategory(category)
        
        navigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)
        navigationOptionsBackup = navigationOptions
        
        form
            +++ Section("Title")
            <<< TextRow() {
                $0.title = "Title"
                $0.placeholder = "Post title"
            }
        
        
        let typeSelection = SelectableSection<ListCheckRow<Bool>>("Type",
                                                                    selectionType: .singleSelection(enableDeselection: true))
        typeSelection.append(ListCheckRow<Bool>() { row in
            row.title = "I want to sell."
            row.selectableValue = true
            row.didSelect()
        })
        
        typeSelection.append(ListCheckRow<Bool>() { row in
            row.title = "I want to buy."
            row.selectableValue = false
        })
        
        form.append(typeSelection)
        
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
        }

    }

}
