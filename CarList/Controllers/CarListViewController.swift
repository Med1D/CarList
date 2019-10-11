//
//  CarListViewController.swift
//  CarList
//
//  Created by Иван Медведев on 04/10/2019.
//  Copyright © 2019 Medvedev. All rights reserved.
//

import UIKit

class CarListViewController: UIViewController, deleteProtocol {

    var cars = [Car]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDefaultCars()
        storageManager.loadCars(to: &cars)
        
        // Set gradient for the title
        guard let navigationController = self.navigationController as? GradientNavigationController else { return }
        navigationController.updateGradient()
        // Hide loadingView with corners setting
        self.loadingView.isHidden = true
        self.loadingView.layer.cornerRadius = 10
    }
    
    
    // MARK: - Actions
    func deleteCell(sender: UIButton, index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) as? CarListTableViewCell, let id = cell.id else { return }
        storageManager.deleteCar(id: id)
        self.cars.remove(at: index)
        UIView.animate(withDuration: 0.2) {
            self.tableView.deleteRows(at: [indexPath], with: .left)
        }
        if cars.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                self.view.isUserInteractionEnabled = false
                self.navigationController?.navigationBar.isUserInteractionEnabled = false
                self.activityIndicator.startAnimating()
                self.loadingView.isHidden = false
                for row in 0..<self.cars.count {
                    self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: UITableView.RowAnimation.none)
                }
                self.navigationController?.navigationBar.isUserInteractionEnabled = true
                self.view.isUserInteractionEnabled = true
                self.loadingView.isHidden = true
                self.activityIndicator.stopAnimating()
            })
        }
    }
    
    // Edit mode
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if sender.title == "Edit" {
            sender.title = "Done"
            self.addButton.isEnabled = false
            self.tableView.isEditing = true
            for (index, cell) in self.tableView.visibleCells.enumerated() {
                (cell as? CarListTableViewCell)?.deleteButton.isHidden = false
                if index % 2 == 0 {
                    cell.shake(fromPositive: true)
                } else {
                    cell.shake(fromPositive: false)
                }
            }
        } else {
            sender.title = "Edit"
            self.addButton.isEnabled = true
            self.tableView.isEditing = false
            for cell in self.tableView.visibleCells {
                (cell as? CarListTableViewCell)?.deleteButton.isHidden = true
                cell.stopShake()
            }
        }
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCar" {
            let newCarVC = segue.destination as! NewCarTableViewController
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            newCarVC.currentCar = cars[indexPath.row]
        }
    }
    
    
    // Save new car and back to CarListViewController
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newCarVC = segue.source as? NewCarTableViewController else { return }
        
        DispatchQueue.main.async {
            newCarVC.saveCar()
            if let newCar = newCarVC.newCar {
                self.cars.append(newCar)
            }
            self.tableView.reloadData()
        }
        
    }
}

// MARK: - TableView delegate
extension CarListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "carIdentifier") as! CarListTableViewCell
        
        let currentCar = cars[indexPath.row]
        cell.carModel.text = currentCar.model
        cell.carManufacturer.text = currentCar.manufacturer
        cell.carYear.text = currentCar.convertDateIntoString()
        cell.carImage.image = UIImage(data: currentCar.imageData! as Data)
        cell.id = currentCar.id
        cell.delegate = self
        cell.index = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.none
    }
    
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            (cell as? CarListTableViewCell)?.deleteButton.isHidden = false
            if indexPath.row % 2 == 0 {
                cell.shake(fromPositive: true)
            } else {
                cell.shake(fromPositive: false)
            }
        } else {
            (cell as? CarListTableViewCell)?.deleteButton.isHidden = true
            cell.stopShake()
        }
    }
}

// MARK: - Add shake animation for view
extension UIView {
    func shake(fromPositive: Bool = true) {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = .infinity
        animation.duration = 0.3
        animation.autoreverses = true
        if fromPositive {
            animation.values = [0.007, -0.007]
        } else {
            animation.values = [-0.007, 0.007]
        }
        layer.add(animation, forKey: "shake")
    }
    
    func stopShake() {
        layer.removeAllAnimations()
    }
}


// MARK: - Load default cars
extension CarListViewController {
    func loadDefaultCars() {
        if let _ = UserDefaults.standard.value(forKey: "firstRun") as? Bool {
            return
        } else {
            UserDefaults.standard.set(false, forKey: "firstRun")
            let _ = storageManager.saveCar(model: "Mustang", manufacturer: "Ford", bodyType: "Coupe", yearOfManufacture: Date(timeIntervalSinceNow: 0), imageData: UIImage(named: "Mustang")?.pngData())
            let _ = storageManager.saveCar(model: "Camaro", manufacturer: "Chevrolet", bodyType: "Coupe", yearOfManufacture: Date(timeIntervalSince1970: 700000000), imageData: UIImage(named: "Camaro")?.pngData())
            let _ = storageManager.saveCar(model: "E200", manufacturer: "Mercedes-Benz", bodyType: "Sedan", yearOfManufacture: Date(timeIntervalSince1970: 900000000), imageData: UIImage(named: "E200")?.pngData())
        }
        
    }
}
