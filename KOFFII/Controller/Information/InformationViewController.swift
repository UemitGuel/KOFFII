import Firebase
import SVProgressHUD
import UIKit

class InformationViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    var db: Firestore!
    var informationBrew = [Information]()
    var informationKnow = [Information]()
    let sections = ["Brewing", "Knowledge"]
    var items = [[Information]]()

    let myGroup = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFirebase()
        SVProgressHUD.show()
        loadInformationObjects { _ in
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        }
    }

    func setupFirebase() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }

    // MARK: - Handling the appearence and disappearnce of the Navigation and Tabbar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        tabBarController?.tabBar.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func loadInformationObjects(completionHandler: @escaping ([[Information]]) -> Void) {
        let brewingRef = db.collection("Information_Brewing")
        let knowledgeRef = db.collection("Information_Knowledge")
        myGroup.enter()
        brewingRef.getDocuments { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    guard let inforation = Information(dictionary: data) else { return }
                    self.informationBrew.append(inforation)
                    
                }
                self.myGroup.leave()
            }
        }
        myGroup.enter()
        knowledgeRef.getDocuments { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    guard let inforation = Information(dictionary: data) else { return }
                    self.informationKnow.append(inforation)
                }
                self.myGroup.leave()
            }
        }
        self.myGroup.notify(queue: .main) {
            print("Finished all requests.")
            self.items.append(self.informationBrew)
            self.items.append(self.informationKnow)
            completionHandler(self.items)
        }
    }
}

extension InformationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "informationCell",
                                                 for: indexPath) as! InformationTableViewCell
        cell.nameLabel?.text = items[indexPath.section][indexPath.row].name
        cell.infoImageView?.image = UIImage(named: items[indexPath.section][indexPath.row].imageName ?? "")
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 220
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "fromInfoToDetailBrewSegue" {
            guard let detailVC = segue.destination as? BrewingDetailViewController else { return }

            if let indexPath = tableView.indexPathForSelectedRow {
                detailVC.passedInformationBrewing = items[indexPath.section][indexPath.row]
            }
        } else if segue.identifier == "fromInfoToDetailKnowSegue" {
            guard let detailVC = segue.destination as? KnowledgeDetailViewController else { return }

            if let indexPath = tableView.indexPathForSelectedRow {
                detailVC.passedInformationKnowledge = items[indexPath.section][indexPath.row]
            }
        }
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            performSegue(withIdentifier: "fromInfoToDetailBrewSegue", sender: self)
        } else if indexPath.section == 1 {
            performSegue(withIdentifier: "fromInfoToDetailKnowSegue", sender: self)
        }
    }

    // MARK: Sections for TableView

    func numberOfSections(in _: UITableView) -> Int {
        return sections.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count != 0 {
            return items[section].count
        } else {
            return 0
        }
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    func tableView(_: UITableView, willDisplayHeaderView view: UIView, forSection _: Int) {

        let header = view as! UITableViewHeaderFooterView
        guard let customFont = UIFont(name: "Staatliches-Regular", size: 40) else {
            fatalError("""
            Failed to load the "CustomFont-Light" font.
            Make sure the font file is included in the project and the font name is spelled correctly.
            """
            )
        }
        header.textLabel?.font = UIFontMetrics.default.scaledFont(for: customFont)
        header.tintColor = .systemBackground
        header.textLabel?.textColor = .label
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 60
    }
}
