//
//  Car+CoreDataClass.swift
//  CarList
//
//  Created by Иван Медведев on 11/10/2019.
//  Copyright © 2019 Medvedev. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Car)
public class Car: NSManagedObject {

    func convertDateIntoString() -> String? {
        guard let year = yearOfManufacture else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let result = dateFormatter.string(from: year as Date)
        return result
    }
    
}
