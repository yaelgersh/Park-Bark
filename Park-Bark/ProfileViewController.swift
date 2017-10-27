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
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createDatePicker(){
        datePicker.datePickerMode = .date
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        
        datePickerText.inputAccessoryView = toolbar
        datePickerText.inputView = datePicker
        
    }
    
    func donePressed(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        
        datePickerText.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
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
        
        UserApp.getInstance().addDog(dog: Dog(name: name, isMale: isMale, birthday: birthday, race: race, size: size))
        
    }
    
    func errorPopup(error : String){
        print(error)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
