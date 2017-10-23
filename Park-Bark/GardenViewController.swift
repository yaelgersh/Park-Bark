//
//  GardenViewController.swift
//  Park-Bark
//
//  Created by Avi on 21/10/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation

class GardenViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {

    var ref: DatabaseReference!
    var refHandle: UInt!
    var gardensList	= [String : [Garden]]()
    let manager = CLLocationManager()
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var gardenTextField: UITextField!
    @IBOutlet weak var gardensMap: MKMapView!
    @IBOutlet weak var addGardenButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    
    let cityPicker = UIPickerView()
    let gardenPicker = UIPickerView()
    
    var cityList = [String]()
    var gardenList = [String]()
    
    var chocenCity : String = ""
    var ChocenGarden : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gardensMap.delegate = self
        initView()
        
        refHandle = ref?.child("Gardens").observe(.value, with: { (snapshot) in
            let dataDict = snapshot.value as! [String: [String: [String : Double]]]
            
            for (city, gardens) in dataDict {
                let cityName : String = city
                var gardenName : String
                var lat : Double
                var lng : Double
                for (garden, location) in gardens {
                    gardenName = garden
                    lat = location["lat"]!
                    lng = location["lng"]!
                    
                    if(self.gardensList[cityName] != nil){
                        self.gardensList[cityName]?.append(Garden(city: cityName, name: gardenName, lat: lat, lng: lng))
                    }
                    else{
                       self.gardensList[cityName] = [Garden(city: cityName, name: gardenName, lat: lat, lng: lng)]
                    }
                }
            }
            self.createCityPicker()
        })
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidDisappear(_ animated: Bool){
        ref.child("Gardens").removeAllObservers()
        print("dis")
    }
    
    deinit {
        print("\(self) - dead")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView()
    {
        cityPicker.tag = 1
        cityPicker.dataSource = self
        cityPicker.delegate = self
        gardenPicker.tag = 2
        gardenPicker.delegate = self
        gardenPicker.dataSource = self
        gardenTextField.isUserInteractionEnabled = false
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        self.gardensMap.showsUserLocation = true
        
        addMapTrackingButton()
        
        ref = Database.database().reference()
        
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    func buildGardenList() -> [String : [Garden]]
    {
        var gardensList = [String : [Garden]]()
        ref = Database.database().reference()
        refHandle = ref?.child("Gardens").observe(.value, with: { (snapshot) in
            let dataDict = snapshot.value as! [String: [String: [String : Double]]]
            
            for (city, gardens) in dataDict {
                let cityName : String = city
                var gardenName : String
                var lat : Double
                var lng : Double
                for (garden, location) in gardens {
                    gardenName = garden
                    lat = location["lat"]!
                    lng = location["lng"]!
                    
                    if(gardensList[cityName] != nil){
                        gardensList[cityName]?.append(Garden(city: cityName, name: gardenName, lat: lat, lng: lng))
                    }
                    else{
                        gardensList[cityName] = [Garden(city: cityName, name: gardenName, lat: lat, lng: lng)]
                    }
                }
            }
            
        })
        
        return gardensList
    }
    
    func createCityPicker()
    {
        cityList = Array(self.gardensList.keys)
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedCity))
        toolbar.setItems([doneButton], animated: false)
        
        cityTextField.inputAccessoryView = toolbar
        cityTextField.inputView = cityPicker
        
        cityPicker.reloadAllComponents()
    }
    
    
    
    func createGardenPicker(){
        gardenList.removeAll()
        let gardens : [Garden] = self.gardensList[cityTextField.text!]!
        for g in gardens{
            gardenList.append(g.name)
        }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedGarden))
        toolbar.setItems([doneButton], animated: false)
        
        gardenTextField.inputAccessoryView = toolbar
        gardenTextField.inputView = gardenPicker
        
        gardenPicker.reloadAllComponents()
    }
    
    func donePressedCity(){
        let selectedValue = cityList[cityPicker.selectedRow(inComponent: 0)]
        addGardenButton.isEnabled = false
        cityTextField.text = selectedValue
        createGardenPicker()
        gardenTextField.isUserInteractionEnabled = true
        gardenTextField.text = ""
        gardenTextField.placeholder = "בחר גינה"
        ChocenGarden = ""
        chocenCity = selectedValue
        self.view.endEditing(true)
    }
    
    func donePressedGarden(){
        let selectedValue = gardenList[gardenPicker.selectedRow(inComponent: 0)]
        gardenTextField.text = selectedValue
        ChocenGarden = selectedValue
        addGardenButton.isEnabled = true
        self.view.endEditing(true)
        createRoute()
    }
    
    func createRoute()
    {
        gardensMap.removeAnnotations(gardensMap.annotations)
        var selectedGarden : Garden?
        let selectedCityGardenList : [Garden] = gardensList[chocenCity]!
        for g in selectedCityGardenList{
            if g.name == ChocenGarden{
                selectedGarden = g
            }
        }
        
        addAnnotationToMap(selectedGarden: selectedGarden!)
        
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.denied)
        {
            let locValue:CLLocationCoordinate2D = (manager.location?.coordinate)!
            let sourceLocation = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
            let destinationLocation = CLLocationCoordinate2D(latitude: (selectedGarden?.lat)!, longitude: (selectedGarden?.lng)!)
            
            let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
            let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
            
            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
            
            let directionRequest = MKDirectionsRequest()
            directionRequest.source = sourceMapItem
            directionRequest.destination = destinationMapItem
            directionRequest.transportType = .automobile
            
            let directions = MKDirections(request: directionRequest)
            
            directions.calculate {
                (response, error) -> Void in
                
                guard let response = response else {
                    if let error = error {
                        print("Error: \(error)")
                    }
                    return
                }
                
                let route = response.routes[0]
                self.gardensMap.removeOverlays(self.gardensMap.overlays)
                self.gardensMap.add((route.polyline), level: MKOverlayLevel.aboveRoads)
                
                let rect = route.polyline.boundingMapRect
                self.gardensMap.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
                
                
                //distance
                if let route = response.routes.first {
                    print("Distance: \(route.distance), ETA: \(route.expectedTravelTime)")
                    if(route.distance >= 1000){
                        self.distanceLabel.isHidden = false
                        self.distanceLabel.text = "מרחק: \(route.distance/1000) ק״מ"
                    }
                    else{
                        self.distanceLabel.isHidden = false
                        self.distanceLabel.text = "מרחק: \(route.distance) מטר"
                    }
                    
                } else {
                    print("Error!")
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1{
            return cityList.count
        }
        else{
            return gardenList.count
        }
    }		
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1{
            return cityList[row]
        }
        else{
            return gardenList[row]
        }
    }
    
    /*
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1{
            addGardenButton.isEnabled = false
            cityTextField.text = cityList[row]
            createGardenPicker()
            gardenTextField.isUserInteractionEnabled = true
            gardenTextField.text = ""
            gardenTextField.placeholder = "בחר גינה"
            ChocenGarden = ""
            chocenCity = cityList[row]
        }
        else{
            gardenTextField.text = gardenList[row]
            ChocenGarden = gardenList[row]
            addGardenButton.isEnabled = true
        }
    }
    */
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.cityTextField.isHidden = true
        self.gardenTextField.isHidden = true
        self.cityPicker.isHidden = false;
        self.gardenPicker.isHidden = false;
        return false
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied){
            showLocationDisabledPopUp()
        }
    }
    
    func showLocationDisabledPopUp(){
        let alertController = UIAlertController(title: "Location Access Disabled", message: "In order to show your location and calculte route we need your permission", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default){(action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    func addMapTrackingButton(){
        let image = UIImage(named: "myLocation") as UIImage?
        let button   = UIButton(type: UIButtonType.system) as UIButton
        button.frame = CGRect(x: 5, y: 5, width: 35, height: 35)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(GardenViewController.centerMapOnUserButtonClicked), for:.touchUpInside)
        self.gardensMap.addSubview(button)
    }
    
    func centerMapOnUserButtonClicked() {
        self.gardensMap.setUserTrackingMode( MKUserTrackingMode.follow, animated: true)
    }
    
    
    func addAnnotationToMap(selectedGarden : Garden){
            
        if(selectedGarden.lat != -1000 && selectedGarden.lng != -1000){
            
            
            let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(selectedGarden.lat, selectedGarden.lng)
            
            //address
            /*
            let l : CLLocation = CLLocation(latitude: selectedGarden.lat, longitude: selectedGarden.lng)
            CLGeocoder().reverseGeocodeLocation(l, completionHandler: { (placemark, error) in
                if error != nil{
                    print("Error in addresing")
                }
                else{
                    if let place = placemark?[0]{
                        print(place.thoroughfare!)
                        print(place.subThoroughfare!)
                        
                    }
                }
            })
             */
            
            let span:MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
                
            let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            gardensMap.setRegion(region, animated: true)
                
            let annotation = MKPointAnnotation()
                
            annotation.coordinate = location
            annotation.title = selectedGarden.name
            annotation.subtitle = selectedGarden.city
            gardensMap.addAnnotation(annotation)
        }
    }
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
