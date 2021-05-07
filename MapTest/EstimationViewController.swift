//
//  EstimationViewController.swift
//  MapTest
//
//  Created by Dian Dinihari on 04/05/21.
//

import UIKit
import CoreLocation
import MapKit

class EstimationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var name = ""
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var motorPicker: UIPickerView!
    @IBOutlet weak var litreLabel: UILabel!
    @IBOutlet weak var estimationLabel: UILabel!
    @IBOutlet weak var estFuelConsumeLabel: UILabel!
    @IBOutlet weak var fillNeedLabel: UILabel!
    @IBOutlet weak var warningFillNeedLabel: UILabel!
    
    var pickerData: [String] = ["Honda Vario 150","Honda Beat Series"]
    var tankLitre: [String] = ["5.5 Litre", "4.2 Litre"]
    var pickerDataTest = 0
    
    var fuelTank : Double = 5.50
    var avgFuelConsumption : Double = 52.90
    var fuelNeeded : Double = 0.00
    
    var bikeDataList : [[String:Any]] = []
    
    let bikeDataVario : [String : Any] = [
        "type"           : "Honda Vario 150",
        "tankCapacity"   : 5.50,
        "estFuelConsume" : 52.9
    ]
    let bikeDataBeat : [String : Any] = [
        "type"           : "Honda Beat Series",
        "tankCapacity"   : 4.20,
        "estFuelConsume" : 60.6
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bikeDataList.append(bikeDataVario)
        bikeDataList.append(bikeDataBeat)
        

        self.motorPicker.delegate = self
        self.motorPicker.dataSource = self
        
        print("EstimationVC : " + name)
        
        fromLabel.text = LocationManager.shared.startLocName
        destinationLabel.text = LocationManager.shared.destLocName
        
        //calculateFuel()
    }
    
    
    func calculateDistance() -> Double{
        var result = 0.00
        let startLoc = LocationManager.shared.startLocCoordinates
        
        let destLoc = LocationManager.shared.destLocCoordinates
        
        let distanceInMeter = (destLoc?.distance(from:(startLoc!)))!
        let distanceInKM = round(distanceInMeter) / 1000
        result = distanceInKM
        
        //distanceLabel.text = String(distanceInKM)
        
        return result
    }
     
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bikeDataList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return bikeDataList[row]["type"] as! String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        generateFromPicker( data: bikeDataList[row] )
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var title = UILabel()
        if let view = view {
            title = view as! UILabel
        }
        
        title.font = UIFont.systemFont(ofSize: 17)
        title.text = bikeDataList[row]["type"] as! String
        title.textColor = UIColor.systemBlue
        title.textAlignment = .center
        generateFromPicker( data: bikeDataList[row] )
        return title
    }
    
    @IBAction func motorPickerPressed(_ sender: Any) {
        
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        
    }
    
    func generateFromPicker(data : [String:Any])
    {
        
        //set the view
        let type = data["type"] as? String ?? ""
        let tankCap = data["tankCapacity"] as? Double ?? 0.00
        let estFuelConsume = data ["estFuelConsume"] as? Double ?? 0.00
        
        
        // start calculating
        //let distanceEst = calculateDistance()
        let distanceEst  = LocationManager.shared.distance / 1000
        let distanceEstStr = String(format: "%.2f", distanceEst)
        let calcFuelNeeded      = distanceEst / estFuelConsume
        let fuelNeededStr       = String(format: "%.2f", calcFuelNeeded)
        let refillCount = calcFuelNeeded / (tankCap - 1.00)
        
        // update layout
        distanceLabel.text = distanceEstStr
        litreLabel.text = String(format: "%.2f", tankCap) + " Litre"
        estFuelConsumeLabel.text = String(format: "%.2f", estFuelConsume) + " Km/L"
        estimationLabel.text = fuelNeededStr + " Litre"
        
        if refillCount >= 1.00 {
            warningFillNeedLabel.isHidden = false
            fillNeedLabel.isHidden = false
            
            fillNeedLabel.text = String(round(refillCount)) + " times"
        } else {
            warningFillNeedLabel.isHidden = true
            fillNeedLabel.isHidden = true
        }
        
    }
    
}
