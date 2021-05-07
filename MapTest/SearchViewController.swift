//
//  SearchViewController.swift
//  MapTest
//
//  Created by Dian Dinihari on 30/04/21.
//

import UIKit
import CoreLocation
import MapKit

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(_ vc: SearchViewController, didSelectLocationWith coordinates: CLLocationCoordinate2D?)
}

class SearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var mapView = MKMapView()
    var locations = [Location]()
    
    weak var delegate: SearchViewControllerDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Where to?"
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private let toLabel: UILabel = {
        let toLabel = UILabel()
        toLabel.text = "To:"
        toLabel.font = .systemFont(ofSize: 17, weight: .regular)
        return toLabel
    }()
    
    public let toField: UITextField = {
        let toField = UITextField()
        toField.placeholder = "Destination"
        toField.layer.cornerRadius = 8
        toField.backgroundColor = .tertiarySystemBackground
        toField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        toField.leftViewMode = .always
        toField.returnKeyType = .search
        return toField
    }()
    
    private let fromLabel: UILabel = {
        let fromLabel = UILabel()
        fromLabel.text = "From:"
        fromLabel.font = .systemFont(ofSize: 17, weight: .regular)
        return fromLabel
    }()
    
    public let checkButton: UIButton = {
        let checkButton = UIButton.init(type: .system)
        checkButton.setTitle("Check", for: .normal)
        checkButton.titleLabel?.font = .systemFont(ofSize: 17)
        checkButton.tintColor = .white
        checkButton.frame = CGRect(x: 0, y: 0, width: 120, height: 50)
        checkButton.backgroundColor = .systemBlue
        checkButton.layer.cornerRadius = 5
        checkButton.titleColor(for: .normal)
        checkButton.addTarget(self, action: #selector(check), for: .touchUpInside)
        return checkButton
    }()
    
    public let fromField: UITextField = {
        let fromField = UITextField()
        fromField.placeholder = "your current location"
        fromField.layer.cornerRadius = 8
        fromField.backgroundColor = .tertiarySystemBackground
        fromField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        fromField.leftViewMode = .always
        return fromField
    }()
    
    private let tableView: UITableView = {
       let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(label)
        view.addSubview(fromLabel)
        view.addSubview(fromField)
        view.addSubview(toField)
        view.addSubview(toLabel)
        view.addSubview(tableView)
        view.addSubview(checkButton)
        
        fromField.delegate = self
        toField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .secondarySystemBackground
        
        checkButton.isEnabled = false
        checkButton.backgroundColor = .systemGray5
        checkButton.tintColor = .black
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        label.sizeToFit()
        label.frame = CGRect(x: 10, y: 15, width: label.frame.size.width, height: label.frame.size.height)
        
        toLabel.sizeToFit()
        toLabel.frame = CGRect(x: 15, y: 75+fromField.frame.size.height, width: fromField.frame.size.width, height: fromField.frame.size.height)
        
        fromLabel.sizeToFit()
        fromLabel.frame = CGRect(x: 15, y: 25+label.frame.size.height, width: toLabel.frame.size.width, height: fromLabel.frame.size.height)
        
        fromField.frame = CGRect(x: 10, y: 30+toLabel.frame.size.height, width: 370, height: 50)
        toField.frame = CGRect(x: 10, y: 145+fromLabel.frame.size.height, width: 370, height: 50)
        
        checkButton.frame = CGRect(x: 120, y: 185+toField.frame.size.height, width: 150, height: 50)
        
        let tableY: CGFloat = checkButton.frame.origin.y+checkButton.frame.size.height+5
        tableView.frame = CGRect(x: 0, y: tableY, width: view.frame.size.width, height: view.frame.size.height-tableY)
    }
    
    //generate location in the tableView after "search" tapped
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        toField.resignFirstResponder()
        if let text = toField.text, !text.isEmpty {
            
            LocationManager.shared.findLocation(with: text) {[weak self] location in
                DispatchQueue.main.async {
                    self?.locations = location
                    self?.tableView.reloadData()
                }
            }
        }
        return true
    }
    
    @objc func check() {
        print("segue to next")
        
        
        let estimationVc = UIStoryboard.init(name: "Main", bundle: nil)
        let estimationViewController = estimationVc.instantiateViewController(withIdentifier: "estimationVC") as! EstimationViewController
        
        self.present(estimationViewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = locations[indexPath.row].title
        cell.textLabel?.numberOfLines = 0
        cell.contentView.backgroundColor = .secondarySystemBackground
        cell.backgroundColor = .secondarySystemBackground
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Notify Map controller to show pin at selected place
        let coordinate = locations[indexPath.row].coordinates
        
        delegate?.searchViewController(self, didSelectLocationWith: coordinate)
        
        LocationManager.shared.destLocCoordinates = locations[indexPath.row].loc
        LocationManager.shared.destLocName = locations[indexPath.row].title
        
        checkButton.isEnabled = true
        checkButton.backgroundColor = .systemBlue
        checkButton.tintColor = .white
        
        getDirection()
        
    }
    
    func getDirection() {
        let request         = MKDirections.Request()
        let startingLoc     = LocationManager.shared.startLocCoordinates?.coordinate
        let startLocMK      = MKPlacemark(coordinate: startingLoc!)
        let destinationLoc  = LocationManager.shared.destLocCoordinates?.coordinate
        let destLocMK       = MKPlacemark(coordinate: destinationLoc!)
        
        request.source      = MKMapItem(placemark: startLocMK)
        request.destination = MKMapItem(placemark: destLocMK)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        var requestDirection = MKDirections(request: request)
        
        
        requestDirection.calculate(completionHandler: { [unowned self ] (response, error ) in
            guard let response = response else { return }
            for route in response.routes {
                
                
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                print("distance = " + String(route.distance))
                
                LocationManager.shared.distance = route.distance
                
            }
        })
        
    }
}

extension SearchViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.fillColor = .systemBlue
        renderer.lineWidth = 5.0
        renderer.alpha = 1.0
        
        return renderer
    }
}
