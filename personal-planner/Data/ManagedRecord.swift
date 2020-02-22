//
//  ManagedRecord.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class ManagedRecord: NSManagedObject {
  @NSManaged var createdAt: Date
  @NSManaged var modifiedAt: Date
}

