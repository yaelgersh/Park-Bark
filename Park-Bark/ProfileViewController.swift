//
//  ProfileViewController.swift
//  Park-Bark
//
//  Created by Yael on 12/10/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var addProfileButton: UIButton!
    @IBOutlet weak var updateProfileButton: UIButton!
    @IBOutlet weak var dogButton: UIButton!
    @IBOutlet weak var dogPic: UIImageView!
    
    @IBOutlet weak var datePickerText: UITextField!
    let datePicker = UIDatePicker()
    var index : Int!
    var day : String!
    var mounth : String!
    var year : String!
    var currentDay : String!
    var currentMounth : String!
    var currentYear : String!
    var firstTime : Bool = true
    
    @IBOutlet weak var ageTitle: UILabel!
    @IBOutlet weak var genderCircle: UIImageView!
    let genderPic = ["bluecircle", "pinkcircle"]
    
    @IBOutlet weak var veryBigButton: UIButton!
    @IBOutlet weak var bigButton: UIButton!
    @IBOutlet weak var mediumButton: UIButton!
    @IBOutlet weak var smallButton: UIButton!
    var buttons: [UIButton]!
    
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var genderSegmentControll: UISegmentedControl!
    
    @IBOutlet weak var bigDogPic: UIImageView!
    @IBOutlet weak var mediumBigDogPic: UIImageView!
    @IBOutlet weak var mediumSmallDogPic: UIImageView!
    @IBOutlet weak var smallDogPic: UIImageView!
    var dogsSizes: [UIImageView]!
    
    
    
    let dogSize = ["small","mediumSmall", "mediumBig", "bigDog"]
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
        
        editProfileButton.isHidden = true
        updateProfileButton.isHidden = true
        addProfileButton.isHidden = true
        
        genderTextField.isHidden = true
        
        buttons = [smallButton, mediumButton, bigButton, veryBigButton]
        dogsSizes = [smallDogPic, mediumSmallDogPic, mediumBigDogPic, bigDogPic]
        
        if(UserApp.getInstance().dogs.count == 0){
            addProfileButton.isHidden = false
            return
        }
        else{
            chooseAction()
            return
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func chooseAction(){
        if UserApp.getInstance().dogs.count > 0 {
            let alert = UIAlertController(title: "", message: "מה תרצה\\י לעשות?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "להוסיף כלב", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
                self.addProfileButton.isHidden = false
            }))
            
            alert.addAction(UIAlertAction(title: "תצוגת פרופיל", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
                let showAlert = UIAlertController(title: "תצוגת פרופיל", message: "בחר\\י כלב", preferredStyle: .alert)
                let dogsCount = UserApp.getInstance().dogs.count
                for i in 0 ..< dogsCount{
                    showAlert.addAction(UIAlertAction(title: "\(UserApp.getInstance().dogs[i].name!)", style: .default, handler: { (action) in
                        showAlert.dismiss(animated: true, completion: nil)
                        self.showDogProfile(index: i)
                    }))
                }
                self.present(showAlert, animated: true, completion: nil)
            }))
            
            if !FBDatabaseManagment.getInstance().anyInTheGarden{
                alert.addAction(UIAlertAction(title: "מחיקת כלב", style: .default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                    
                    let delAlert = UIAlertController(title: "מחיקת פרופיל", message: "בחר\\י כלב", preferredStyle: .alert)
                    let dogsCount = UserApp.getInstance().dogs.count
                    for i in 0 ..< dogsCount{
                        delAlert.addAction(UIAlertAction(title: "\(UserApp.getInstance().dogs[i].name!)", style: .default, handler: { (action) in
                            delAlert.dismiss(animated: true, completion: nil)
                            let warnAlert = UIAlertController(title: "מחיקת פרופיל", message: "האם למחוק את \(UserApp.getInstance().dogs[i].name!)", preferredStyle: .alert)
                            warnAlert.addAction(UIAlertAction(title: "מחק", style: UIAlertActionStyle.default, handler: { (action) in
                                warnAlert.dismiss(animated: true, completion: nil)
                                self.deletDog(index: i)
                                self.chooseAction()
                            }))
                            warnAlert.addAction(UIAlertAction(title: "ביטול", style: UIAlertActionStyle.default, handler: { (action) in
                                warnAlert.dismiss(animated: true, completion: nil)
                                self.chooseAction()
                            }))
                            self.present(warnAlert, animated: true, completion: nil)
                            
                        }))
                    }
                    self.present(delAlert, animated: true, completion: nil)
                }))
            }
            
            alert.addAction(UIAlertAction(title: "חזרה לתפריט הראשי", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
                _ = self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            addProfileButton.isHidden = false
        }
    }
    
    func deletDog(index: Int){
        //UserApp.getInstance().dogs.remove(at: id)
        UserApp.getInstance().removeDog(dog: UserApp.getInstance().dogs[index], index: index)
    }
    
    func showDogProfile(index : Int){
        editProfileButton.isHidden = false
        
        self.index = index
        let dog = UserApp.getInstance().dogs[index]
        
        dogPic.alpha = 1
        dogButton.setTitle("", for: .normal)
        dogButton.isEnabled = false
        
        if (dog.urlImage) != nil{
            //let url = URL(fileURLWithPath: UserApp.getInstance().dogs[id].urlImage!)
            let url = URL(string: UserApp.getInstance().dogs[index].urlImage!)
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if error != nil{
                    print(error!)
                    return
                }
                DispatchQueue.main.async {
                    self.dogPic.image = UIImage(data: data!)
                    
                }
            })
            task.resume()
        }
        
        nameTextField.text = dog.name
        nameTextField.isEnabled = false
        
        genderSegmentControll.isEnabled = false
        if(dog.isMale!){
            genderTextField.text = "זכר"
            genderCircle.image = UIImage(named:genderPic[0])
        }
        else{
            genderTextField.text = "נקבה"
            genderCircle.image = UIImage(named:genderPic[1])
        }
        genderTextField.isHidden = false
        genderTextField.isEnabled = false
        
        ageTitle.text = "גיל: "
        
        var tempDate = DateComponents()
        tempDate.year = dog.year
        tempDate.month = dog.mounth
        tempDate.day = dog.day
        
        let now = Date()
        let calendar = Calendar.current
        let dogBirthday = calendar.date(from: tempDate)
        
        let ageComponents = calendar.dateComponents([.year], from: dogBirthday!, to: now)
        let theAge = ageComponents.year!
        
        datePickerText.text = "\(theAge)"
        datePickerText.isEnabled = false
        
        raceTextField.text = dog.race
        raceTextField.isEnabled = false
        
        size = dog.size
        for i in 0 ..< buttons.count{
            buttons[i].isEnabled = false
        }
        setClicked(size: dog.size)
        
    }
    
    func chooseDog(){
        let alert = UIAlertController(title: "", message: "מה תרצה\\י לעשות?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "להוסיף כלב", style: .default, handler: { (action) in
            self.addProfileButton.isHidden = false
        }))
        let count : Int = UserApp.getInstance().dogs.count
        for i in 0 ..< count{
            alert.addAction(UIAlertAction(title: "הצג את \(UserApp.getInstance().dogs[i].name!)", style: .default, handler: { (action) in
                self.showDogProfile(index: i)
                self.editProfileButton.isHidden = false
            }))
        }
        
        alert.addAction(UIAlertAction(title: "חזרה לתפריט הראשי", style: .default, handler: { (action) in
            _ = self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
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
        imagePickerController.allowsEditing = true
        
        let actionSheet = UIAlertController(title: "מאגר תמונות", message: "בחר מאגר תמונות", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "מצלמה", style: .default, handler: {(action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
            else{
                // cant run in debug mode
                print("המצלמה לא זמינה")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "אלבום תמונות", style: .default, handler: {(action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "ביטול", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            dogPic.image = editedImage
            dogPic.alpha = 1
            
            dogButton.setTitle("", for: .normal)
            
        }
        else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
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
    
    //
    
    @IBAction func pickedBig(_ sender: Any) {
        setClicked(size: 3)
    }
    
    @IBAction func pickedMediumBig(_ sender: Any) {
        setClicked(size: 2)
    }
    
    @IBAction func pickedMadiumSmall(_ sender: Any) {
        setClicked(size: 1)
    }
    
    @IBAction func pickedSmall(_ sender: Any) {
        setClicked(size: 0)
    }
    
    func setClicked(size: Int){
        self.size = size
        
        for i in 0 ..< dogsSizes.count{
            if i == size{
                dogsSizes[i].image = UIImage(named: dogSize[i]+GREEN)
            }
            else{
                dogsSizes[i].image = UIImage(named: dogSize[i]+BLACK)
            }
        }
    }
    
    @IBAction func addDog(_ sender: Any) {
        if nameTextField.text == ""{
            errorPopup(error: "שם הכלב הוא שדה חובה")
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
            errorPopup(error: "יום הולדת הכלב הוא שדה חובה")
            return
        }
        
        if Int(currentYear)! < Int(year)!{
            errorPopup(error: "תאריך יום ההולדת לא אפשרי")
            return
        }
        if Int(currentYear)! == Int(year)!{
            if Int(currentMounth)! < Int(mounth)!{
                errorPopup(error: "תאריך יום ההולדת לא אפשרי")
                return
            }
            if Int(currentMounth)! == Int(mounth)!{
                if Int(currentDay)! < Int(day)!{
                    errorPopup(error: "תאריך יום ההולדת לא אפשרי")
                    return
                }
            }
            
        }
        birthday = datePickerText.text
        
        if raceTextField.text == ""{
            errorPopup(error: "גזע הכלב הוא שדה חובה")
            return
        }
        race = raceTextField.text
        
        if size == -1{
            errorPopup(error: "גודל הכלב הוא שדה חובה")
            return
        }
        
        
        
        if UserApp.getInstance().addDog(name: name, isMale: isMale, year: Int(year)! , mounth : Int(mounth)! , day: Int(day)!, race: race, size: size, dogPic: dogPic.image!){
            let alert = UIAlertController(title: "", message: "\(name!) נוסף\\ה בהצלחה.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "הוסף\\י עוד כלב", style: .default, handler: { (action) in
                self.resetThePage()
            }))
            alert.addAction(UIAlertAction(title: "חזרה", style: .default, handler: { (action) in
                _ = self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            errorPopup(error: "\(name!) כבר ברשימת הכלבים שלך");
        }
        
    }
    
    
    @IBAction func editProfile(_ sender: Any) {
        updateProfileButton.isHidden = false
        editProfileButton.isHidden = true
        genderTextField.isHidden = false
        
        let dog = UserApp.getInstance().dogs[index]
        
        dogPic.alpha = 0.4
        dogButton.setTitle("", for: .normal)
        dogButton.isEnabled = true
        
        nameTextField.isEnabled = true
        
        genderTextField.isHidden = true
        genderSegmentControll.isEnabled = true
        if(dog.isMale!){
            genderSegmentControll.selectedSegmentIndex = 0
        }
        else{
            genderSegmentControll.selectedSegmentIndex = 1
        }
        
        ageTitle.text = "נולדתי בתאריך: "
        year = String(dog.year)
        mounth = String(dog.mounth)
        day = String(dog.day)
        
        datePickerText.text = "\(day!)/\(mounth!)/\(year!)"
        datePickerText.isEnabled = true
        
        raceTextField.isEnabled = true
        
        for i in 0 ..< buttons.count{
            buttons[i].isEnabled = true
        }
        
    }
    
    @IBAction func updateProfile(_ sender: Any) {
        updateProfileButton.isHidden = true
        editProfileButton.isHidden = false
        genderTextField.isHidden = true

        let dog: Dog! = UserApp.getInstance().dogs[index]
        
        
        
        if nameTextField.text == ""{
            errorPopup(error: "שם הכלב הוא שדה חובה")
            return
        }
        for i in 0 ..< UserApp.getInstance().dogs.count{
            if i != index{
                if(nameTextField.text == UserApp.getInstance().dogs[i].name!){
                    errorPopup(error: "יש כלב אחר בשם \(nameTextField.text!) ");
                    return
                }
            }
        }
        dog.name = nameTextField.text
        
        if genderSegmentControll.selectedSegmentIndex == 0{
            dog.isMale = true
        }
        else{
            dog.isMale = false
        }
        
        if datePickerText.text == ""{
            errorPopup(error: "יום הולדת הכלב הוא שדה חובה")
            return
        }
        
        if Int(currentYear)! < Int(year)!{
            errorPopup(error: "תאריך יום ההולדת לא אפשרי")
            return
        }
        if Int(currentYear)! == Int(year)!{
            if Int(currentMounth)! < Int(mounth)!{
                errorPopup(error: "תאריך יום ההולדת לא אפשרי")
                return
            }
            if Int(currentMounth)! == Int(mounth)!{
                if Int(currentDay)! < Int(day)!{
                    errorPopup(error: "תאריך יום ההולדת לא אפשרי")
                    return
                }
            }
            
        }
        dog.year = Int(year)
        dog.mounth = Int(mounth)
        dog.day = Int(day)
        
        if raceTextField.text == ""{
            errorPopup(error: "גזע הכלב הוא שדה חובה")
            return
        }
        dog.race = raceTextField.text
        
        if size == -1{
            errorPopup(error: "גודל הכלב הוא שדה חובה")
            return
        }
        dog.size = size
        
        
        UserApp.getInstance().updateDog(index: index, image: dogPic.image!)
        showDogProfile(index: index)
    }
    
    func errorPopup(error : String){
        let alert = UIAlertController(title: "שגיאה", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "אישור", style: .default, handler: { (action) in
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
        
        setClicked(size: -1)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
