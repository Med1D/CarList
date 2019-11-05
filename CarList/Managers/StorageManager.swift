//
//  StorageManager.swift
//  CarList
//
//  Created by Иван Медведев on 10/10/2019.
//  Copyright © 2019 Medvedev. All rights reserved.
//

import UIKit
import CoreData
//swiftlint:disable:next prohibited_global_constants
let storageManager = StorageManager()

final class StorageManager
{

	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "CarModel")
		container.loadPersistentStores { _, error in
			if let error = error as NSError? {
				fatalError("FATAL ERROR")
			}
		}
		return container
	}()

	func saveCar(model: String?,
				 manufacturer: String?,
				 bodyType: String?,
				 yearOfManufacture: Date?,
				 imageData: Data?) -> Car? {
		guard let carEntity = NSEntityDescription.entity(forEntityName: "Car",
														 in: self.persistentContainer.viewContext) else { return nil }

		let newCar = NSManagedObject(entity: carEntity, insertInto: self.persistentContainer.viewContext)
		newCar.setValue(imageData as NSData?, forKey: "imageData")
		newCar.setValue(model, forKey: "model")
		newCar.setValue(manufacturer, forKey: "manufacturer")
		newCar.setValue(bodyType, forKey: "bodyType")
		newCar.setValue(yearOfManufacture as NSDate?, forKey: "yearOfManufacture")
		newCar.setValue(UUID().uuidString, forKey: "id")

		do {
			try self.persistentContainer.viewContext.save()
			return newCar as? Car
		}
		catch {
			print(error.localizedDescription)
		}
		return nil
	}

	func deleteCar(id: String) {
		let fetchRequest = NSFetchRequest<Car>(entityName: "Car")
		fetchRequest.predicate = NSPredicate(format: "id = %@", id)
		do {
			let objects = try storageManager.persistentContainer.viewContext.fetch(fetchRequest)
			let object = objects[0]
			storageManager.persistentContainer.viewContext.delete(object)
			do {
				try storageManager.persistentContainer.viewContext.save()
			}
			catch {
				print(error.localizedDescription)
			}
		}
		catch {
			print(error.localizedDescription)
		}
	}

	func saveContext() {
		let context = self.persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			}
			catch {
				fatalError("FATAL ERROR")
			}
		}
	}

	func loadCars(to cars: inout [Car]) {
		let context = self.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<Car>(entityName: "Car")
		do {
			cars = try context.fetch(fetchRequest)
		}
		catch {
			print(error.localizedDescription)
		}
	}
}
