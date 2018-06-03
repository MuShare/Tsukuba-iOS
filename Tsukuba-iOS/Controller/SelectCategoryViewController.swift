import UIKit

class SelectCategoryViewController: UIViewController {

    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    let dao = DaoManager.shared
    let config = Config.shared
    
    var categories: [Category]!
    var selectedCategory: Category!
    var lastSelectedCell: CategoryCollectionViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        categories = dao.categoryDao.findEnable()
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case R.segue.selectCategoryViewController.createMessageSegue.identifier:
            let destination = segue.destination as! CreateMessageViewController
            destination.category = selectedCategory
        default:
            break
        }
    }

    // MARK: Action
    @IBAction func choosed(_ sender: Any) {
        if lastSelectedCell == nil {
            return
        }
        self.performSegue(withIdentifier: R.segue.selectCategoryViewController.createMessageSegue, sender: self)
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SelectCategoryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / CGFloat(config.columns)
        return CGSize(width: width, height: width + 25)
    }
    
}

extension SelectCategoryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = categories[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.categoryIdentifier, for: indexPath)!
        cell.nameLabel.text = category.name
        cell.iconImageView.kf.setImage(with: URL(string: createUrl(category.icon!)))
        return cell
    }

}

extension SelectCategoryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if lastSelectedCell != nil {
            lastSelectedCell?.iconImageView.kf.setImage(with: URL(string: createUrl(selectedCategory.icon!)))
        }
        lastSelectedCell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell
        lastSelectedCell?.iconImageView.image = R.image.category_selected()
        selectedCategory = categories[indexPath.row]
    }
    
}
