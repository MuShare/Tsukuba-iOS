import UIKit
import Eureka
import NVActivityIndicatorView

class CreateMessageViewController: FormViewController, NVActivityIndicatorViewable {

    let dao = DaoManager.shared
    let messgaeManager = MessageManager.shared
    
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

        selections = dao.selectionDao.findEnableByCategory(category)
        
        self.setCustomBack()
        self.view.tintColor = Color.main
        ListCheckRow<String>.defaultCellSetup = { cell, row in
            cell.tintColor = Color.main
        }
        
        navigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)
        navigationOptionsBackup = navigationOptions
        
        form
            +++ Section(R.string.localizable.message_basic_info())
            
            /**
            <<< SegmentedRow<String>() {
                $0.title = R.string.localizable.message_type_choose()
                $0.options = [R.string.localizable.message_type_sell(), R.string.localizable.message_type_buy()]
                $0.value = R.string.localizable.message_type_sell()
            }.onChange({ (row) in
                self.sell = (row.value! == R.string.localizable.message_type_sell())
            })
            */
            
            <<< TextRow() {
                $0.title = R.string.localizable.message_title()
                $0.placeholder = R.string.localizable.message_title_placeholder()
            }.onChange({ (row) in
                self.messageTitle = row.value
            })
        
            <<< IntRow(){
                $0.title = R.string.localizable.message_price()
                $0.placeholder = "0"
            }.onChange({ (row) in
                self.price = row.value ?? 0
            })
        
            <<< TextAreaRow() {
                $0.placeholder = R.string.localizable.message_introduction_placeholder()
            }.onChange({ (row) in
                self.introduction = row.value ?? ""
            })
        
        for selection in selections {
            let selectionSection = SelectableSection<ListCheckRow<String>>(selection.name!,
                                                                           selectionType: .singleSelection(enableDeselection: true))
            for option in dao.optionDao.findEnableBySelection(selection) {
                selectionSection <<< ListCheckRow<String>() { row in
                    row.title = option.name
                    row.selectableValue = option.oid
                }
            }
            form +++ selectionSection
            selectionSections.append(selectionSection)
        }

    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.createMessageViewController.createPictureSegue.identifier {
            let destination = segue.destination as! PictureViewController
            destination.mid = mid
            // Set done type for PictureViewController.
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            let lastViewController = viewControllers[viewControllers.count - 2]
            if lastViewController.isKind(of: MessagesViewController.self) {
                destination.doneType = .pop2
            } else if lastViewController.isKind(of: SelectCategoryViewController.self) {
                destination.doneType = .dismiss
            }
        }
    }
    
    // MARK: Action
    @IBAction func createMessage(_ sender: Any) {
        if messageTitle == nil {
            showTip(R.string.localizable.message_title_empty())
            return
        }
        
        var oids: [String] = []
        for section in selectionSections {
            if let oid = section.selectedRow()?.value {
                oids.append(oid)
            }
        }

        startAnimating()
        
        messgaeManager.create(title: messageTitle!,
                       introudction: introduction,
                       sell: sell,
                       price: price,
                       oids: oids,
                       cid: category.cid!)
        { (success, mid) in
            self.stopAnimating()
            if success {
                self.mid = mid!
                self.performSegue(withIdentifier: R.segue.createMessageViewController.createPictureSegue.identifier, sender: self)
            } else {
                self.showTip(R.string.localizable.create_message_fail())
            }
        }
    }
    
}
