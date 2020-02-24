//
//  ConversionUtils.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-22.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation

protocol NumberConvertible {
  var numberValue: NSNumber { get }
}

protocol DoubleConvertible {
  var doubleValue: Double { get }
}

protocol StringConvertible {
  var stringValue: String { get }
  var stringCurrencyValue: String { get }
}

protocol IntConvertible {
  var intValue: Int { get }
  var int16Value: Int16 { get }
}

extension Double: NumberConvertible, StringConvertible {
  var stringValue: String {
    String(format: "%.0f", self)
  }
  
  var stringCurrencyValue: String {
    String(format: "%.2f", self)
  }
  
  var numberValue: NSNumber {
    NSNumber(value: self)
  }
}

extension NSNumber: StringConvertible {
  var stringValue: String {
    String(format: "%.0f", self.doubleValue)
  }
  
  var stringCurrencyValue: String {
    String(format: "%.2f", self.doubleValue)
  }
}

extension Int: NumberConvertible, StringConvertible {
  var numberValue: NSNumber {
    NSNumber(value: self)
  }
  
  var stringValue: String {
    "\(self)"
  }
  
  var stringCurrencyValue: String {
    String(format: "%.2f", self)
  }
}

extension Int16: NumberConvertible, StringConvertible {
  var numberValue: NSNumber {
    NSNumber(value: self)
  }
  
  var stringValue: String {
    "\(self)"
  }
  
  var stringCurrencyValue: String {
    String(format: "%.2f", self)
  }
  
  var intValue: Int {
    Int(self)
  }
}

extension String: NumberConvertible, DoubleConvertible, IntConvertible {
  var numberValue: NSNumber {
    NSNumber(value: Double(self) ?? 0)
  }
  
  var doubleValue: Double {
    self.numberValue.doubleValue
  }
  
  var intValue: Int {
    Int(self) ?? 0
  }
  
  var int16Value: Int16 {
    Int16(self) ?? 0
  }
}

extension Date {
  static var monthNow: Int16 {
    Int16(Calendar.current.component(.month, from: Date()))
  }
  
  static var yearNow: Int16 {
    Int16(Calendar.current.component(.year, from: Date()))
  }
  
  static var dayNow: Int16 {
    Int16(Calendar.current.component(.day, from: Date()))
  }
  
  static func with(day: Int16?, month: Int16?, year: Int16?) -> Date {
    DateComponents(calendar: Calendar.current, year: year?.intValue ?? Date.yearNow.intValue, month: month?.intValue ?? Date.monthNow.intValue, day: day?.intValue ?? Date.dayNow.intValue).date ?? Date()
  }
  
  var day: Int16 {
    get {
      Int16(Calendar.current.component(.day, from: self))
    }
    set {
      let dateComponents = DateComponents(calendar: Calendar.current, year: self.year.intValue, month: self.month.intValue, day: newValue.intValue)
      self = dateComponents.date ?? self
    }
  }
  
  var month: Int16 {
    get {
      Int16(Calendar.current.component(.month, from: self))
    }
    set {
      let dateComponents = DateComponents(calendar: Calendar.current, year: self.year.intValue, month: newValue.intValue, day: self.day.intValue)
      self = dateComponents.date ?? self
    }
  }
  
  var year: Int16 {
    get {
      Int16(Calendar.current.component(.year, from: self))
    }
    set {
      let dateComponents = DateComponents(calendar: Calendar.current, year: newValue.intValue, month: self.month.intValue, day: self.day.intValue)
      self = dateComponents.date ?? self
    }
  }
  
  mutating func nextMonth() {
    if self.month + 1 > 12 {
      self.month = 1
      self.year = self.year + 1
    } else {
      self.month = self.month + 1
    }
  }
  
  mutating func previousMonth() {
    if self.month - 1 < 0 {
      self.month = 12
      self.year = self.year - 1
    } else {
      self.month = self.month - 1
    }
  }
  
  func currentMonthAndYear() -> String {
    return DateFormatter().monthSymbols[self.month.intValue - 1] + " \(self.year.intValue)"
  }
}
