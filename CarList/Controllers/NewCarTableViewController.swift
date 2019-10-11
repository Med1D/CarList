//
//  NewCarTableViewController.swift
//  CarList
//
//  Created by Иван Медведев on 09/10/2019.
//  Copyright © 2019 Medvedev. All rights reserved.
//

import UIKit
import CoreData

class NewCarTableViewController: UITableViewController {

    var currentCar: Car!
    var newCar: Car!
    
    var imageIsChanged: Bool = false
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var manufacturerTextField: UITextField!
    @IBOutlet weak var bodyTypeTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var yearSwitch: UISwitch!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTableView()
        setupEditScreen()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set gradient for the large title
        guard let navigationController = self.navigationController as? GradientNavigationController else { return }
            navigationController.setGradient(size: CGSize(width: UIApplication.shared.statusBarFrame.width, height: UIApplication.shared.statusBarFrame.height + 110))
    }
    
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let libraryIcon = #imageLiteral(resourceName: "photo")
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
            let library = UIAlertAction(title: "Library", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            library.setValue(libraryIcon, forKey: "image")
            library.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
    
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(library)
            actionSheet.addAction(cancel)
            present(actionSheet, animated: true)
            
        } else {
            self.view.endEditing(true)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 250
        } else if indexPath.row == 5 {
            if yearSwitch.isOn {
                return 150
            } else {
                return 0
            }
        } else {
            return 75
        }
    }

    
    
    // MARK: - Navigation
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Actions
    func saveCar() {
        
        let image = imageIsChanged ? imageView.image : #imageLiteral(resourceName: "emptyCar")
        let imageData = image?.pngData()
        
        let date = yearSwitch.isOn ? datePicker.date : nil
        
        if currentCar != nil {
            currentCar.setValue(imageData as NSData?, forKey: "imageData")
            currentCar.setValue(modelTextField.text, forKey: "model")
            currentCar.setValue(manufacturerTextField.text, forKey: "manufacturer")
            currentCar.setValue(bodyTypeTextField.text, forKey: "bodyType")
            currentCar.setValue(date as NSDate?, forKey: "yearOfManufacture")
        } else {
            newCar = storageManager.saveCar(model: modelTextField.text, manufacturer: manufacturerTextField.text, bodyType: bodyTypeTextField.text, yearOfManufacture: date, imageData: imageData)
        }
    }
    
    // MARK: - Settings for tableView
    func settingsTableView() {
        // Remove separators after last cell
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1.0))
        
        // Set delegates for text fields
        modelTextField.delegate = self
        manufacturerTextField.delegate = self
        bodyTypeTextField.delegate = self
        
        
        // Show/hide yearTextField, datePickerCell and datePicker at the beggining
        changeSwitchValue(sender: yearSwitch)
        // Add target for yearSwitch
        yearSwitch.addTarget(self, action: #selector(changeSwitchValue(sender:)), for: .valueChanged)
        // Add target for datePicker
        datePicker.addTarget(self, action: #selector(spinDatePicker(sender:)), for: .valueChanged)
        // Add target for modelTextField (empty -> saveButton is disabled, !empty -> saveButton is enabled)
        saveButton.isEnabled = false
        modelTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    // yearSwitch changes value on/off
    @objc func changeSwitchValue(sender: UISwitch) {
        if sender.isOn {
            self.yearTextField.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.datePickerCell.frame.size.height = CGFloat(150)
                self.datePicker.isHidden = false
                // Set value to yearTextField when yearSwitch was switched on
                self.spinDatePicker(sender: self.datePicker)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.layoutIfNeeded()
                }
            }
        } else {
            self.yearTextField.isHidden = true
            self.datePickerCell.frame.size.height = CGFloat(0)
            self.datePicker.isHidden = true
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
            }
        }
    }
    
    
    // datePicker was spinned -> yearTextField changes value
    @objc func spinDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        yearTextField.text = dateFormatter.string(from: sender.date)
    }
    
    
    // Settings for the edit screen
    func setupEditScreen() {
        if currentCar != nil {
            setupNavigationBar()
            imageIsChanged = true
            self.imageView.contentMode = .scaleAspectFill
            self.imageView.image = UIImage(data: currentCar.imageData! as Data)
            self.modelTextField.text = currentCar.model
            self.manufacturerTextField.text = currentCar.manufacturer
            self.bodyTypeTextField.text = currentCar.bodyType
            
            if let date = currentCar.yearOfManufacture {
                self.yearSwitch.isOn = true
                changeSwitchValue(sender: yearSwitch)
                self.yearTextField.text = currentCar.convertDateIntoString()
                self.datePicker.date = date as Date
            }
        }
    }
    
    
    // Settings for the title, save button and back button (edit screen)
    func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentCar.model
        saveButton.isEnabled = true
    }
}


// MARK: - Text field delegate
extension NewCarTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldChanged() {
        if modelTextField.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
}

// MARK: - Work with image
extension NewCarTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageIsChanged = true
        
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - Update gradient for title after scroll
extension NewCarTableViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let navigationController = self.navigationController as? GradientNavigationController else { return }
        DispatchQueue.main.async {
            navigationController.updateGradient()
        }
    }
}
