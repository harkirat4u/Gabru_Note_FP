//
//  AddNoteVC.swift
//  Note_FinalProject
//
//  Created by Harkirat Singh on 2020-06-21.
//  Copyright © 2020 Harkirat Singh. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation
import AVFoundation


class AddNoteVC: UIViewController, CLLocationManagerDelegate,UIImagePickerControllerDelegate ,UINavigationControllerDelegate, AVAudioRecorderDelegate{
    var selectedNote: Notes?
      weak var delegate: NoteTableViewController?
    @IBOutlet weak var updateBtn: UIBarButtonItem!
    @IBOutlet var txttitle: UITextField!
    @IBOutlet var txtDesc: UITextView!
    @IBOutlet var locationitem: UIBarButtonItem!
    @IBOutlet var notesImageView: UIImageView!
    @IBOutlet weak var locationTF: UILabel!
    var latitudeString:String = ""
    var listArray = [NSManagedObject]();
    var longitudeString:String = ""
    var locationManager:CLLocationManager!
    var note:Notes!
    var folder : Folder?
    var userIsEditing = true
    var context:NSManagedObjectContext!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        context = appDelegate.persistentContainer.viewContext
        if (userIsEditing == true) {
            locationitem.isEnabled = true
            txttitle.text = note.title!
            txtDesc.text = note.desc!
            self.notesImageView.image = UIImage(data: note.imageData! as Data)
            locationTF.text = String(note.latitude)
        }
        else {
            txtDesc.text = ""
            locationitem.isEnabled = true
            
        }
    }
    
    @IBAction func audionBtn(_ sender: Any) {
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        note.latitude = userLocation.coordinate.latitude
        note.longitude = userLocation.coordinate.longitude
    }
    
    
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }
    
    
    @IBAction func updateAction(_ sender: UIBarButtonItem) {
        
            determineMyCurrentLocation()
                            note.title = txttitle.text!
                            note.desc = txtDesc.text!
                            let imageData = notesImageView.image!.pngData() as NSData?
                            note.imageData = imageData as Data?
                            note.folder = self.folder
             
                        do {
                            try context.save()
                            listArray.append(note);
                            let alertBox = UIAlertController(title: "Alert", message: "Data updated Successfully", preferredStyle: .alert)
                            alertBox.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                                self.navigationController?.popViewController(animated: true)

                               // self.datecompare()
                            }))
                            self.present(alertBox, animated: true, completion: nil)
                        }
    }
    
    
    
    @IBAction func btnSave(_ sender: Any) {
        determineMyCurrentLocation()
        if (txtDesc.text!.isEmpty) {
            return
        }
        
        
        if (userIsEditing == true) {
            note.desc = txtDesc.text!
        }
        else {
            
            self.note = Notes(context:context)
          note.setValue(Date().currentTimeMillis(), forKey:"created")
            if (txttitle.text!.isEmpty) {
                note.title = "No Title"
            }
            else{
                note.title = txttitle.text!
            }
            note.desc = txtDesc.text!
            let imageData = notesImageView.image!.pngData() as NSData?
            note.imageData = imageData as Data?
            
            note.folder = self.folder
        }
        
        do {
            try context.save()
            listArray.append(note);
            let alertBox = UIAlertController(title: "Alert", message: "Data Save Successfully", preferredStyle: .alert)
            alertBox.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alertBox, animated: true, completion: nil)
        }
        catch {
           
            let alertBox = UIAlertController(title: "Error", message: "Error", preferredStyle: .alert)
            alertBox.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertBox, animated: true, completion: nil)
        }
        if (userIsEditing == false) {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func showDialog() {
        let alert = UIAlertController(title: "Note Image", message: "Please add title of  note.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        openDialog();
    }
    
    
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            let imageData = image.pngData() as NSData?
            
            self.notesImageView.image = UIImage(data: imageData! as Data)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func openDialog(){
        let alert = UIAlertController(title: "Note", message: "Pick image from", preferredStyle: .alert)
        
        
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                var imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { action in
            
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                var imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
            
        }))
           alert.addAction(UIAlertAction(title: "Remove", style: .default, handler: { action in
                      
                self.notesImageView.image = UIImage(named: "placeholder.png");
                      
                  }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "noteLocSegue") {
            let locationVC = segue.destination as! NoteLocationVC
            let mapLatitude:Double = note.latitude
            let mapLongitude:Double = note.longitude
            locationVC.lat = mapLatitude
            locationVC.long = mapLongitude
            
        }
    }
    
}
extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
