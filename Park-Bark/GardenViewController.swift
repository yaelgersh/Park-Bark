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
import MessageUI

class GardenViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate {

    var gardensList	= [String : [Garden]]()
    let manager = CLLocationManager()
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var gardenTextField: UITextField!
    @IBOutlet weak var gardensMap: MKMapView!
    @IBOutlet weak var addGardenButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    
    let cityPicker = UIPickerView()
    let gardenPicker = UIPickerView()
    
    var cityListNames = [String]()
    var gardenListNames = [String]()
    
    var chocenCityName : String = ""
    var chocenGardenName : String = ""
    
    var chocenGarden : Garden?
    
    let user = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gardensMap.delegate = self
        initView()
        gardensList = FBDatabaseManagment.getInstance().getGardensList()
        self.createCityPicker()
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
        
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    func createCityPicker()
    {
        cityListNames = Array(self.gardensList.keys)
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedCity))
        toolbar.setItems([doneButton], animated: false)
        
        cityTextField.inputAccessoryView = toolbar
        cityTextField.inputView = cityPicker
        
        cityPicker.reloadAllComponents()
    }
    
    
    
    func createGardenPicker(){
        gardenListNames.removeAll()
        let gardens : [Garden] = self.gardensList[cityTextField.text!]!
        for g in gardens{
            gardenListNames.append(g.name)
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
        let selectedValue = cityListNames[cityPicker.selectedRow(inComponent: 0)]
        addGardenButton.isEnabled = false
        cityTextField.text = selectedValue
        createGardenPicker()
        gardenTextField.isUserInteractionEnabled = true
        gardenTextField.text = ""
        gardenTextField.placeholder = "בחר גינה"
        chocenGardenName = ""
        chocenCityName = selectedValue
        self.view.endEditing(true)
    }
    
    func donePressedGarden(){
        let selectedValue = gardenListNames[gardenPicker.selectedRow(inComponent: 0)]
        gardenTextField.text = selectedValue
        chocenGardenName = selectedValue
        addGardenButton.isEnabled = true
        self.view.endEditing(true)
        createRoute()
        chocenGarden = getSelectedGarden()
    }
    
    func createRoute()
    {
        gardensMap.removeAnnotations(gardensMap.annotations)
        var selectedGarden : Garden?
        let selectedCityGardenList : [Garden] = gardensList[chocenCityName]!
        for g in selectedCityGardenList{
            if g.name == chocenGardenName{
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
            directionRequest.transportType = .walking
            
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
    
    func getSelectedGarden() -> Garden?{
        for garden in gardensList[chocenCityName]!{
            if garden.name == chocenGardenName{
                return garden
            }
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1{
            return cityListNames.count
        }
        else{
            return gardenListNames.count
        }
    }		
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1{
            return cityListNames[row]
        }
        else{
            return gardenListNames[row]
        }
    }
    
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
        let alertController = UIAlertController(title: "Location Access Disabled", message: "על מנת לזהות את מיקומך אנחנו צריכים את אישורך", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "ביטול", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "הגדרות", style: .default){(action) in
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
    
    @IBAction func addGardenClcik(_ sender: Any) {
        if UserApp.getInstance().garden != nil{
            FBDatabaseManagment.getInstance().stopObserverForInGarden()
        }
        FBDatabaseManagment.getInstance().saveGarden(garden: chocenGarden!, id: user!)
        _ = navigationController?.popViewController(animated: true)
    }
 
    @IBAction func sendEmail(_ sender: Any) {
        let mailComposeVC = configureMailController()
        if MFMailComposeViewController.canSendMail(){
            self.present(mailComposeVC, animated: true, completion: nil)
        }
        else{
            showmailError()
        }
    }
    
    func configureMailController() -> MFMailComposeViewController{
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["avi.elgal@gmail.com", "yaelgersh92@gmail.com"])
        mailComposerVC.setSubject("Park&Bark new garden")
        mailComposerVC.setMessageBody("add new garden request", isHTML: false)
        
        return mailComposerVC
    }
    
    func showmailError(){
        let errorAlert = UIAlertController(title: "לא ניתן לשלוח את ההודעה ", message: "המכשיר שלך לא תומך בשליחת הודעות email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "אישור", style: .default, handler: nil)
        errorAlert.addAction(dismiss)
        self.present(errorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
