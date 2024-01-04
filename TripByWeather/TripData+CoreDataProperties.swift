//
//  TripData+CoreDataProperties.swift
//  TripByWeather
//
//  Created by Fevin Patel on 2023-12-07.
//
//

import Foundation
import CoreData


extension TripData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TripData> {
        return NSFetchRequest<TripData>(entityName: "TripData")
    }

    @NSManaged public var city: String?
    @NSManaged public var icon: String?
    @NSManaged public var temp: Double
    @NSManaged public var todo: String?


}

extension TripData : Identifiable {

}
