//
//  CalendarHelper.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation

import Foundation

class CalendarHelper: ObservableObject {
  @Published var month: Int16!
  @Published var year: Int16!
  
  class func monthNow() -> Int16 {
    Int16(Calendar.current.component(.month, from: Date()))
  }
  
  class func yearNow() -> Int16 {
    Int16(Calendar.current.component(.year, from: Date()))
  }
  
  class func dayNow() -> Int16 {
    Int16(Calendar.current.component(.day, from: Date()))
  }
  
  init() {
    self.month = CalendarHelper.monthNow()
    self.year = CalendarHelper.yearNow()
  }
  
  func nextMonth() {
    if self.month + 1 > 11 {
      self.month = 0
      self.year = self.year + 1
    } else {
      self.month = self.month + 1
    }
  }
  
  func previousMonth() {
    if self.month - 1 < 0 {
      self.month = 11
      self.year = self.year - 1
    } else {
      self.month = self.month - 1
    }
  }
  
  func currentMonthAndYear() -> String {
    return DateFormatter().monthSymbols[self.month.intValue] + " \(self.year!.intValue)"
  }
}
