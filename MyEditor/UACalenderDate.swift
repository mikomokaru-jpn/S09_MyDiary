//------------------------------------------------------------------------------
//  UACalenderDate.swift
//------------------------------------------------------------------------------
import Cocoa
class UACalenderDate: NSObject {
    var year:Int = 0
    var month:Int = 0
    var day:Int = 0
    var weekday:Int = 0
    var thisMonthFlag:Bool = false
    var firstDayFlag:Bool = false
    var lastDayFlag:Bool = false
    var holidayFlag:Bool = false
    var currentFlag:Bool = false
}
