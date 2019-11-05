//
//  Car+CoreDataProperties.swift
//  CarList
//
//  Created by Иван Медведев on 11/10/2019.
//  Copyright © 2019 Medvedev. All rights reserved.
//
//

import Foundation
import CoreData

extension Car
{

	@nonobjc public class func fetchRequest() -> NSFetchRequest<Car> {
		return NSFetchRequest<Car>(entityName: "Car")
	}

	@NSManaged public var imageData: NSData?
	@NSManaged public var model: String?
	@NSManaged public var manufacturer: String?
	@NSManaged public var bodyType: String?
	@NSManaged public var yearOfManufacture: NSDate?
	@NSManaged public var id: String?
}
