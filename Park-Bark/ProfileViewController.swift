//
//  ProfileViewController.swift
//  Park-Bark
//
//  Created by Yael on 12/10/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var dogButton: UIButton!
    @IBOutlet weak var dogPic: UIImageView!
    
    @IBOutlet weak var datePickerText: UITextField!
    let datePicker = UIDatePicker()
    var day : String!
    var mounth : String!
    var year : String!
    var currentDay : String!
    var currentMounth : String!
    var currentYear : String!
    var firstTime : Bool = true

    @IBOutlet weak var genderCircle: UIImageView!
    let genderPic = ["bluecircle", "pinkcircle"]
    
    
    @IBOutlet weak var genderSegmentControll: UISegmentedControl!
   
    @IBOutlet weak var bigDogPic: UIImageView!
    @IBOutlet weak var mediumBigDogPic: UIImageView!
    @IBOutlet weak var mediumSmallDogPic: UIImageView!
    @IBOutlet weak var smallDogPic: UIImageView!
    let dogSize = ["bigDog", "mediumBig", "mediumSmall", "small"]
    let GREEN = "Green"
    let BLACK = "Black"
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var raceTextField: UITextField!
    
    var name : String!
    var race : String!
    var isMale : Bool = false
    var birthday : String!
    var size : Int = -1
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDatePicker()
        
        dogPic.layer.cornerRadius = dogPic.frame.height/2
        dogPic.clipsToBounds = true
        
        if(UserApp.getInstance().dogs.count == 0){
            return
        }
        else if(UserApp.getInstance().dogs.count == 1){
            showDogProfile(id : 0)
            return
        }
        else{
            chooseDog()
            return
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showDogProfile(id : Int){
        let dog = UserApp.getInstance().dogs[id]
        
        nameTextField.text = dog.name
        nameTextField.isEnabled = false
        
        genderSegmentControll.setEnabled(false, forSegmentAt: 0)
        genderSegmentControll.setEnabled(false, forSegmentAt: 1)
        if(dog.isMale){
            genderSegmentControll.selectedSegmentIndex = 1
        }
        else{
            genderSegmentControll.selectedSegmentIndex = 0
        }
        
        datePickerText.text = "\(dog.day!).\(dog.mounth!).\(dog.year!)"
        datePickerText.isEnabled = false
        
        raceTextField.text = dog.race
        raceTextField.isEnabled = false
        
        

    }
    
    func chooseDog(){
        
    }
    
    func createDatePicker(){
        datePicker.datePickerMode = .date
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        
        datePickerText.inputAccessoryView = toolbar
        datePickerText.inputView = datePicker
        if firstTime{
            firstTime = false
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            
            
            dateFormatter.dateFormat = "y"
            currentYear = dateFormatter.string(from: datePicker.date)
            
            dateFormatter.dateFormat = "M"
            currentMounth = dateFormatter.string(from: datePicker.date)
            
            dateFormatter.dateFormat = "d"
            currentDay = dateFormatter.string(from: datePicker.date)
        }
    }
    
    func donePressed(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        
        datePickerText.text = dateFormatter.string(from: datePicker.date)
        
        
        dateFormatter.dateFormat = "y"
        year = dateFormatter.string(from: datePicker.date)
        
        dateFormatter.dateFormat = "M"
        mounth = dateFormatter.string(from: datePicker.date)
        
        dateFormatter.dateFormat = "d"
        day = dateFormatter.string(from: datePicker.date)

        
        self.view.endEditing(true)
        
        print("##current: ", currentYear, currentMounth, currentDay)
        print("##picked: ", year, mounth, day)
    }
    
    @IBAction func pickADog(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
            else{
                // cant run in debug mode
                print("Camera not available")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            dogPic.image = image
            dogPic.alpha = 1
            
            dogButton.setTitle("", for: .normal)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func genderChanged(_ sender: Any) {
        genderCircle.image = UIImage(named:genderPic[genderSegmentControll.selectedSegmentIndex])
        
    }

    
    
    @IBAction func pickedBig(_ sender: Any) {
        size = 0
        bigDogPic.image = UIImage(named: dogSize[0]+GREEN)
        mediumBigDogPic.image = UIImage(named: dogSize[1]+BLACK)
        mediumSmallDogPic.image = UIImage(named: dogSize[2]+BLACK)
        smallDogPic.image = UIImage(named: dogSize[3]+BLACK)
    }

    @IBAction func pickedMediumBig(_ sender: Any) {
        size = 1
        bigDogPic.image = UIImage(named: dogSize[0]+BLACK)
        mediumBigDogPic.image = UIImage(named: dogSize[1]+GREEN)
        mediumSmallDogPic.image = UIImage(named: dogSize[2]+BLACK)
        smallDogPic.image = UIImage(named: dogSize[3]+BLACK)
    }
    
    @IBAction func pickedMadiumSmall(_ sender: Any) {
        size = 2
        bigDogPic.image = UIImage(named: dogSize[0]+BLACK)
        mediumBigDogPic.image = UIImage(named: dogSize[1]+BLACK)
        mediumSmallDogPic.image = UIImage(named: dogSize[2]+GREEN)
        smallDogPic.image = UIImage(named: dogSize[3]+BLACK)
    }
    
    @IBAction func pickedSmall(_ sender: Any) {
        size = 3
        bigDogPic.image = UIImage(named: dogSize[0]+BLACK)
        mediumBigDogPic.image = UIImage(named: dogSize[1]+BLACK)
        mediumSmallDogPic.image = UIImage(named: dogSize[2]+BLACK)
        smallDogPic.image = UIImage(named: dogSize[3]+GREEN)
    }
    
    
    @IBAction func addDog(_ sender: Any) {
        if nameTextField.text == ""{
            errorPopup(error: "error add dog - name is empty")
            return
        }
        name = nameTextField.text
        
        if genderSegmentControll.selectedSegmentIndex == 0{
            isMale = true
        }
        else{
            isMale = false
        }
        
        if datePickerText.text == ""{
            errorPopup(error: "error add dog - birthday is empty")
            return
        }
        
        if Int(currentYear)! < Int(year)!{
            errorPopup(error: "birthday must be in the past")
            return
        }
        if Int(currentYear)! == Int(year)!{
            if Int(currentMounth)! < Int(mounth)!{
                errorPopup(error: "birthday must be in the past")
                return
            }
            if Int(currentMounth)! == Int(mounth)!{
                if Int(currentDay)! < Int(day)!{
                    errorPopup(error: "birthday must be in the past")
                    return
                }
            }
            
        }
        birthday = datePickerText.text
        
        if raceTextField.text == ""{
            errorPopup(error: "error add dog - race is empty")
            return
        }
        race = raceTextField.text
        
        if size == -1{
            errorPopup(error: "error add dog - pick size")
            return
        }
        
        if UserApp.getInstance().addDog(name: name, isMale: isMale, year: Int(year)! , mounth : Int(mounth)! , day: Int(day)!, race: race, size: size){
            let alert = UIAlertController(title: "Success", message: "\(name!) successfully added.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Add another one", style: .default, handler: { (action) in
                self.resetThePage()
            }))
            alert.addAction(UIAlertAction(title: "Back", style: .default, handler: { (action) in
                _ = self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            errorPopup(error: "you allready added \(name!)");
        }
        
    }
    
    func errorPopup(error : String){
        let alert = UIAlertController(title: "ERROR", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func resetThePage(){
        dogPic.image = #imageLiteral(resourceName: "dog")
        dogPic.alpha = 0.4
        dogButton.setTitle("הוסף תמונה", for: .normal)
        
        nameTextField.text = ""
        datePickerText.text = ""
        raceTextField.text = ""
        
        size = -1
        bigDogPic.image = UIImage(named: dogSize[0]+BLACK)
        mediumBigDogPic.image = UIImage(named: dogSize[1]+BLACK)
        mediumSmallDogPic.image = UIImage(named: dogSize[2]+BLACK)
        smallDogPic.image = UIImage(named: dogSize[3]+BLACK)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
