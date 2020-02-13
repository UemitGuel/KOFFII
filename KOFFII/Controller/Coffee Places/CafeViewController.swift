import FirebaseFirestore
import UIKit
import SwiftUI
import SVProgressHUD
import MapKit
import CoreLocation

class CafeViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 1000
    let mapView = MKMapView()
    let mapFunctions = MapFunctions()
    var userLocationEnabled: Bool = false
    
    enum Section: CaseIterable {
        case cafes
    }
    
    let cafeController = CafeController()
    var dataSource: UITableViewDiffableDataSource<Section, CafeController.Cafe>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, CafeController.Cafe>! = nil
    
    @IBOutlet weak var addCoffeePlace: UIBarButtonItem!
    @IBAction func addCoffeePlaceTapped(_ sender: UIBarButtonItem) {
        let hostView = UIHostingController(rootView: AddCoffeePlaceView(dismiss: dismiss))
        navigationController?.present(hostView, animated: true)
    }
    
    func dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var hoodPickerView: UIPickerView!
    
    @IBOutlet var wifiButton: FeatureButton!
    @IBOutlet var wifiLabel: UILabel!
    
    @IBOutlet var foodButton: FeatureButton!
    @IBOutlet var foodLabel: UILabel!
    
    @IBOutlet var veganButton: FeatureButton!
    @IBOutlet var veganLabel: UILabel!
    
    @IBOutlet var cakeButton: FeatureButton!
    @IBOutlet var cakeLabel: UILabel!
    
    @IBOutlet var plugButton: FeatureButton!
    @IBOutlet var plugLabel: UILabel!
    
    var userRequestedFeatures: [Feature] = []
    var userChoosenNeighborhoods: [Neighborhood] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()

        setupViewController()
        configureDataSource()
        SVProgressHUD.show()
        cafeController.fetchAndConfigureUnfilteredCafes {
            self.updateUI()
            SVProgressHUD.dismiss()
        }
    }
    
    func setupViewController() {
        // eliminate 1pt line
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    @IBAction func featureButtonTapped(_ sender: UIButton) {
        let featureBF = FeatureButtonFunctions()
        switch sender {
        case wifiButton:
            featureBF.handleButtonTap(userRequestedFeatures: &userRequestedFeatures,
                                      feature: .wifi, button: wifiButton, label: wifiLabel)
        case foodButton:
            featureBF.handleButtonTap(userRequestedFeatures: &userRequestedFeatures,
                                      feature: .food, button: foodButton, label: foodLabel)
        case veganButton:
            featureBF.handleButtonTap(userRequestedFeatures: &userRequestedFeatures,
                                      feature: .vegan, button: veganButton, label: veganLabel)
        case cakeButton:
            featureBF.handleButtonTap(userRequestedFeatures: &userRequestedFeatures,
                                      feature: .cake, button: cakeButton, label: cakeLabel)
        case plugButton:
            featureBF.handleButtonTap(userRequestedFeatures: &userRequestedFeatures,
                                      feature: .plugin, button: plugButton, label: plugLabel)
        default:
            break
        }
        updateUI()
    }
}

extension CafeViewController: UITableViewDelegate {
    
    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
        performSegue(withIdentifier: Constants.segues.citytoDetail, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == Constants.segues.citytoDetail {
            let cityDetailVC = segue.destination as! CafeDetailViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                if let identifier = dataSource.itemIdentifier(for: indexPath) {
                    cityDetailVC.passedCafe = identifier
                }
            }
        }
    }
}

extension CafeViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return neighborhoods.count
    }
    
}

extension CafeViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return neighborhoods[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let featureBF = FeatureButtonFunctions()
        featureBF.filterForNeighborhoods(userChoosenNeighborhoods: &userChoosenNeighborhoods, selectedHood: neighborhoods[row])
        updateUI()
    }
    
}

extension CafeViewController {
    
    func configureDataSource() {
        
        self.dataSource = UITableViewDiffableDataSource
            <Section, CafeController.Cafe>(tableView: tableView) {
                (tableView: UITableView, indexPath: IndexPath, item: CafeController.Cafe) -> UITableViewCell? in
                let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "DefaultCell")
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .none
                cell.textLabel?.text = item.name
                cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
                if self.userLocationEnabled {
                    guard let locValue: CLLocationCoordinate2D = self.locationManager.location?.coordinate else { fatalError() }
                    print(locValue)
                    let userLocation = MKMapPoint(locValue)
                    let cafeLocation = MKMapPoint(CLLocationCoordinate2DMake(item.latitude ?? 0, item.longitude ?? 0))
                    let distance = userLocation.distance(to: cafeLocation)
                    let distanceAsStringRounded = self.mapFunctions.self.mapDistanceForDisplay(distance)
                    cell.detailTextLabel?.text = String(distanceAsStringRounded)
                } else {
                    cell.detailTextLabel?.text = item.neighborhood
                }
                cell.detailTextLabel?.textColor = .secondaryLabel
                cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
                cell.imageView?.image = UIImage(asset: Asset.coffeeIcon)
                return cell
        }
        self.dataSource.defaultRowAnimation = .fade
    }
    
    func updateUI(animated: Bool = true) {
        var cafes = cafeController.filteredCafes(userRequestedFeatures: userRequestedFeatures, userChoosenNeighborhoods: userChoosenNeighborhoods).sorted { $0.name < $1.name }
        if userLocationEnabled {
            guard let locValue: CLLocationCoordinate2D = self.locationManager.location?.coordinate else { fatalError() }
            let userLocation = MKMapPoint(locValue)
            cafes = cafes.sorted {
                userLocation.distance(to: MKMapPoint(CLLocationCoordinate2DMake($0.latitude ?? 0, $0.longitude ?? 0))) < userLocation.distance(to: MKMapPoint(CLLocationCoordinate2DMake($1.latitude ?? 0, $1.longitude ?? 0)))
            }
        }
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, CafeController.Cafe>()
        currentSnapshot.appendSections([.cafes])
        currentSnapshot.appendItems(cafes, toSection: .cafes)
        self.dataSource.apply(currentSnapshot, animatingDifferences: animated)
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            userLocationEnabled = false
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            userLocationEnabled = true
            break
        case .denied:
            userLocationEnabled = false
            //Show alert to turn on permission
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //Show alert parents denied this permission
            break
        case .authorizedAlways:
            break
        @unknown default:
            fatalError()
        }
    }
}

extension CafeViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}


