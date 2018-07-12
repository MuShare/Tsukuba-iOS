//
//  InterfaceController.swift
//  Tsukuba-watchOS Extension
//
//  Created by Meng Li on 2018/07/04.
//  Copyright © 2018 MuShare. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBOutlet var roomTable: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        for i in 0...(roomTable.numberOfRows - 1) {
            let row = roomTable.rowController(at: i) as! RoomRowController
            row.nameLabel.setText("Test \(i)")
        }
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
    }

}
