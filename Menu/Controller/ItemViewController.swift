//
//  ItemViewController.swift
//  Menu
//
//  Created by Illya Gordiyenko on 2018-04-23.
//  Copyright © 2018 Illya Gordiyenko. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var menuManager:MenuManager!
    var currentItem:Item!

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var detailsField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    
    @IBOutlet weak var itemImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(tappedImage))
        itemImageView.isUserInteractionEnabled = true
        itemImageView.addGestureRecognizer(imageTap)
        
        self.reload()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reload() {
        nameField.text = currentItem.name
        detailsField.text = currentItem.detail
        priceField.text = String(format:"%.2f", currentItem.price)
        
        if let imagePath = currentItem.imagePath {
            
            // Retrive image data from filepath and convert it to UIImage
            if FileManager.default.fileExists(atPath: imagePath) {
                
                if let contentsOfFilePath = UIImage(contentsOfFile: imagePath) {
                    self.itemImageView.image = contentsOfFilePath
                }
            }
            
        }
    }
    
    @IBAction func updateItem(_ sender: UIButton) {
        
        var updatedPrice:Double?
        if let priceString = priceField.text, let tempPrice = Double(priceString) {
            updatedPrice = tempPrice
        }
        
        currentItem = menuManager.updateItem(item: currentItem,
                                             name: nameField.text,
                                             detail: detailsField.text,
                                             imagePath: nil,
                                             price: updatedPrice)
        menuManager.save()
        
        self.reload()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteItem(_ sender: UIButton) {
        
        menuManager.remove(objectID: currentItem.objectID)
        menuManager.save()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    @objc func tappedImage(_ sender: UITapGestureRecognizer) {
        // Make sure device has a camera
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            // Setup and present default Camera View Controller
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // Dismiss the view controller a
        picker.dismiss(animated: true, completion: nil)
        
        // Get the picture we took
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.itemImageView.image = image
        
        // Save imageData to filePath
        // Get access to shared instance of the file manager
        let fileManager = FileManager.default
        
        // Get the URL for the users home directory
        let documentsURL =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Get the document URL as a string
        let documentPath = documentsURL.path
        
        // Create filePath URL by appending final path component (name of image)
        let filePath = documentsURL.appendingPathComponent("\(String(image.description)).png")
        
        // Check for existing image data
        do {
            // Look through array of files in documentDirectory
            let files = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
            
            for file in files {
                // If we find existing image filePath delete it to make way for new imageData
                if "\(documentPath)/\(file)" == filePath.path {
                    try fileManager.removeItem(atPath: filePath.path)
                }
            }
        } catch {
            print("Could not add image from document directory: \(error)")
        }
        
        
        // Create imageData and write to filePath
        do {
            if let pngImageData = UIImagePNGRepresentation(image) {
                try pngImageData.write(to: filePath, options: .atomic)
            }
        } catch {
            print("couldn't write image")
        }
        
        currentItem = menuManager.updateItem(item: currentItem,
                                             name: nil,
                                             detail: nil,
                                             imagePath: filePath.path,
                                             price: nil)
        menuManager.save()
        
        self.reload()
        
    }
    

}
