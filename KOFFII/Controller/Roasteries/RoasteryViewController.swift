import FirebaseFirestore
import UIKit

class RoasteryViewController: UIViewController {
    var roasteries: [Roastery] = []

    @IBOutlet var roasterTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        fetchRoasteries { _ in
            self.roasterTableView.reloadData()
        }
    }

    func setupViewController() {
        // eliminate 1pt line
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }

    private func fetchRoasteries(completionHandler: @escaping ([Roastery]) -> Void) {
        Constants.refs.firestoreRoasteries.getDocuments { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    guard let roastery = Roastery(dictionary: data) else { return }
                    self.roasteries.append(roastery)
                }
                completionHandler(self.roasteries)
            }
        }
    }
}

extension RoasteryViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return roasteries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .default , reuseIdentifier: "DefaultCell")
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = roasteries[indexPath.row].name
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        cell.imageView?.image = UIImage(asset: Asset.roasterIcon)
        return cell
    }
}

extension RoasteryViewController: UITableViewDelegate {

    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
        performSegue(withIdentifier: Constants.segues.roasterToDetail, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == Constants.segues.roasterToDetail {
            let roasteryDetailVC = segue.destination as! RoasteryDetailViewController
            if let indexPath = roasterTableView.indexPathForSelectedRow {
                roasteryDetailVC.passedRoastery = roasteries[indexPath.row]
            }
        }
    }
}
