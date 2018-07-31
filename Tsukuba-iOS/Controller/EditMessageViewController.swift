import UIKit
import Eureka
import NVActivityIndicatorView

class EditMessageViewController: FormViewController, NVActivityIndicatorViewable {

    let dao = DaoManager.shared
    let messageManager = MessageManager.shared
    
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
        self.view.tintColor = .main
        ListCheckRow<String>.defaultCellSetup = { cell, row in
            cell.tintColor = .main
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
        if segue.identifier == R.segue.editMessageViewController.editPictureSegue.identifier {
            let destination = segue.destination as! PictureViewController
            destination.doneType = .pop
            destination.mid = message.mid
        }
    }
    
    @IBAction func modifyMessage(_ sender: Any) {
        if messageTitle == nil {
            showTip("Please input a post title.")
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
                              oids: oids) { (success, tip) in
            self.stopAnimating()
            if (success) {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showTip(tip!)
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
                row.title = R.string.localizable.message_edit_pictures()
                row.presentationMode = .segueName(segueName: R.segue.editMessageViewController.editPictureSegue.identifier, onDismiss: nil)
            }
            
            <<< ButtonRow() { row in
                row.title = R.string.localizable.message_close_title()
                row.cellStyle = .value1
                row.cell.accessoryType = .disclosureIndicator
                row.cell.tintColor = .main
            }.onCellSelection({ (cell, row) in
                let alertController = UIAlertController(title: R.string.localizable.message_close_title(),
                                                        message: R.string.localizable.message_close_content(),
                                                        preferredStyle: .alert)
                let close = UIAlertAction(title: R.string.localizable.yes_name(), style: .destructive) { action in
                    self.closeMessage()
                }
                let cancel = UIAlertAction(title: R.string.localizable.cancel_name(), style: .cancel)
                alertController.addAction(close)
                alertController.addAction(cancel)
                self.present(alertController, animated: true, completion: nil)
            })
            
            +++ Section(R.string.localizable.message_basic_info())
            
            <<< TextRow() { row in
                row.title = R.string.localizable.message_title()
                row.value = message.title!
                row.placeholder = R.string.localizable.message_title_placeholder()
                }.onChange({ row in
                    self.messageTitle = row.value
                })
            
            <<< IntRow(){ row in
                row.title = R.string.localizable.message_price()
                row.value = message.price
                row.placeholder = "0"
                }.onChange({ row in
                    self.price = row.value ?? 0
                })
            
            <<< TextAreaRow() { row in
                row.value = message.introduction!
                row.placeholder = R.string.localizable.message_introduction_placeholder()
                }.onChange({ row in
                    self.introduction = row.value ?? ""
                })
        
        for selection in selections {
            let selectionSection = SelectableSection<ListCheckRow<String>>(selection.name!,
                                                                           selectionType: .singleSelection(enableDeselection: true))
            for option in dao.optionDao.findEnableBySelection(selection) {
                selectionSection <<< ListCheckRow<String>() { row in
                    row.tag = option.oid
                    row.title = option.name
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
    
    func closeMessage() {
        startAnimating()
        messageManager.close(messageId) { (success, tip) in
            self.stopAnimating()
            if (success) {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showTip(tip!)
            }
        }
    }

}
