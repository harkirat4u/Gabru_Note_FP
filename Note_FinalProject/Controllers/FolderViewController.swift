//
//  ViewController.swift
//  Note_FinalProject
//
//  Created by Harkirat Singh on 2020-06-20.
//  Copyright © 2020 Harkirat Singh. All rights reserved.
//

import UIKit
import CoreData
class FolderViewController: UITableViewController {
     // create a folder array to populate the table
       var folders = [Folder]()
        var editMode: Bool = false
    @IBOutlet weak var deleteBtn: UIBarButtonItem!
    @IBOutlet var editBtn: UITableView!
    // create a context
       let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

       override func viewDidLoad() {
         deleteBtn.isEnabled=false
           super.viewDidLoad()
           print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
           loadFolder()
       }
       
       override func viewWillAppear(_ animated: Bool) {
           tableView.reloadData()
       }
       
       //MARK: - Data manipulation methods
       
       func loadFolder() {
           let request: NSFetchRequest<Folder> = Folder.fetchRequest()
           
           do {
               folders = try context.fetch(request)
           } catch {
               print("Error loading folders \(error.localizedDescription)")
           }
           
           tableView.reloadData()
       }
       
       func saveFolders() {
           do {
               try context.save()
               tableView.reloadData()
           } catch {
               print("Error saving folders \(error.localizedDescription)")
           }
       }

       // MARK: - Table view data source

       override func numberOfSections(in tableView: UITableView) -> Int {
           // #warning Incomplete implementation, return the number of sections
           return 1
       }

       override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           // #warning Incomplete implementation, return the number of rows
           return folders.count
       }

       
    
    @IBAction func deleteAction(_ sender: UIBarButtonItem) {
         if let indexPaths = tableView.indexPathsForSelectedRows {
             let rows = (indexPaths.map {$0.row}).sorted(by: >)
             
                 let _ = rows.map {deleteNote(folder: folders[$0])}
             let _ = rows.map {folders.remove(at: $0)}
             
             tableView.reloadData()
             
             saveFolders()
    }
    }
    
    @IBAction func editActionBtn(_ sender: UIBarButtonItem) {
         editMode = !editMode
                         
                         tableView.setEditing(editMode ? true : false, animated: true)
              deleteBtn.isEnabled = !deleteBtn.isEnabled
    }
    
    
    //Swipe Delete
            override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
             if editingStyle == .delete {

                 deleteNote(folder: folders[indexPath.row])
                           saveFolders()
                           folders.remove(at: indexPath.row)
                           // Delete the row from the data source
                           tableView.deleteRows(at: [indexPath], with: .fade)
             } else if editingStyle == .insert {
                 
             }
         }
    
    
    
    
       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "folderCell", for: indexPath)
           cell.textLabel?.text = folders[indexPath.row].name
           cell.textLabel?.textColor = .black
           cell.detailTextLabel?.textColor = .black
           cell.detailTextLabel?.text = "\(folders[indexPath.row].notes?.count ?? 0)"
           cell.imageView?.image = UIImage(systemName: "folder")
         
           return cell
       }

       //Code For add folder method
       @IBAction func addFolder(_ sender: UIBarButtonItem) {
           
           var textField = UITextField()
           let alert = UIAlertController(title: "Add New Folder", message: "", preferredStyle: .alert)
           let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
               let folderNames = self.folders.map {$0.name}
            guard !folderNames.contains(textField.text) else {self.showAlert(); return}
               let newFolder = Folder(context: self.context)
               newFolder.name = textField.text!
               self.folders.append(newFolder)
               self.saveFolders()
           }
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
           // change the font color of cancel action
           cancelAction.setValue(UIColor.orange, forKey: "titleTextColor")
           
           alert.addAction(addAction)
           alert.addAction(cancelAction)
           alert.addTextField { (field) in
               textField = field
               textField.placeholder = "Folder Name"
           }
           
           present(alert, animated: true, completion: nil)
       }
     
     //Delete Fuction
       
         func deleteNote(folder: Folder) {
               context.delete(folder)
           }
        
            
         
         
       // Alert Box
      func showAlert() {
          let alert = UIAlertController(title: "Name Taken", message: "Please choose another name", preferredStyle: .alert)
          
          let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
          okAction.setValue(UIColor.orange, forKey: "titleTextColor")
          alert.addAction(okAction)
          present(alert, animated: true, completion: nil)
      }
         
         //Seuge Control
         
       override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
               if (editMode==false) {
                   return true
               } else {
                   return false
               }
           }
        
       //Performing segue
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           let destination = segue.destination as! NoteTableViewController
           if let indexPath = tableView.indexPathForSelectedRow {
               destination.selectedFolder = folders[indexPath.row]
           }
           
       }

}


