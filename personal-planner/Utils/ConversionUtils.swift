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
  static var monthNow: Int {
    Calendar.current.component(.month, from: Date())
  }
  
  static var yearNow: Int {
    Calendar.current.component(.year, from: Date())
  }
  
  static var dayNow: Int {
    Calendar.current.component(.day, from: Date())
  }
  
  static func with(day: Int?, month: Int?, year: Int?) -> Date {
    DateComponents(calendar: Calendar.current, year: year ?? Date.yearNow, month: month ?? Date.monthNow, day: day ?? Date.dayNow).date ?? Date()
  }
  
  var day: Int {
    get {
      Calendar.current.component(.day, from: self)
    }
    set {
      let dateComponents = DateComponents(calendar: Calendar.current, year: self.year, month: self.month, day: newValue)
      self = dateComponents.date ?? self
    }
  }
  
  var month: Int {
    get {
      Calendar.current.component(.month, from: self)
    }
    set {
      let dateComponents = DateComponents(calendar: Calendar.current, year: self.year, month: newValue, day: self.day)
      self = dateComponents.date ?? self
    }
  }
  
  var year: Int {
    get {
      Calendar.current.component(.year, from: self)
    }
    set {
      let dateComponents = DateComponents(calendar: Calendar.current, year: newValue, month: self.month, day: self.day)
      self = dateComponents.date ?? self
    }
  }
  
    var currentMonthPredicate: NSPredicate {
      let start = self.startOfMonth() as NSDate
      let end = self.endOfMonth() as NSDate
      return NSPredicate(format: "%@ <= date AND date <= %@", start, end)
    }
  
  func endOfMonth() -> Date {
    Calendar.current.dateInterval(of: .month, for: self)!.end
  }

  func startOfMonth() -> Date {
    Calendar.current.dateInterval(of: .month, for: self)!.start
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
    return DateFormatter().monthSymbols[self.month - 1] + " \(self.year)"
  }
}
