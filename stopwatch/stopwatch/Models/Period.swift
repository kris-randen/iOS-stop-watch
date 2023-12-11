//
//  Quarter.swift
//  stopwatch
//
//  Created by Krishnaswami Rajendren on 12/11/23.
//

import Foundation

struct Period: Identifiable, Codable {
    var id: UUID = UUID()  // Unique identifier for each quarter
    let index: Int
    let startTime: Date
    let endTime: Date
    static let TimeInterval = Constants.TIME_PERIOD
    static let NumSeconds = Int(TimeInterval)
    
    static func getFirstPeriodStart(from wakeUpTime: Date, using calendar: Calendar) -> Date? {
        let minute = calendar.component(.minute, from: wakeUpTime)
        let quarterIndex = minute / 15
        let startMinute = quarterIndex * 15
        
        return calendar.date(
            bySettingHour: calendar.component(.hour, from: wakeUpTime),
            minute: startMinute,
            second: 0,
            of: wakeUpTime) ?? nil
    }
    
    static func create(at index: Int = 0, from startTime: Date = Date.now, using calendar: Calendar = Calendar.current) -> Period? {
        guard let quarterStart = calendar.date(byAdding: .minute, value: index * Constants.NUM_MINS_IN_A_QUARTER, to: startTime) else { return nil }
        let quarterEnd = calendar.date(byAdding: .minute, value: Constants.NUM_MINS_IN_A_QUARTER - 1, to: quarterStart)!
        return Period(index: index + 1, startTime: quarterStart, endTime: quarterEnd)
    }
    
    static func createAll(from firstQuarterStart: Date, using calendar: Calendar) -> [Period] {
        return Constants.RANGE_OF_QUARTERS_IN_A_DAY.compactMap {
            Period.create(at: $0, from: firstQuarterStart, using: calendar)
        }
    }
    
    static func getCurrentPeriodIndexI(at time: Date = Date.now, with wakeUpTime: Date, using calendar: Calendar) -> Int? {
        let wakeUpComponents = calendar.dateComponents([.hour, .minute], from: wakeUpTime)
        let currentComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        let wakeUpMinutes = (wakeUpComponents.hour ?? 0) * Constants.NUM_MINS_IN_AN_HOUR + (wakeUpComponents.minute ?? 0)
        let currentMinutes = (currentComponents.hour ?? 0) * Constants.NUM_MINS_IN_AN_HOUR + (currentComponents.minute ?? 0)
        
        let elapsedMinutes = currentMinutes - wakeUpMinutes
        
        guard elapsedMinutes >= 0 else { return nil }
        
        return (elapsedMinutes / Constants.NUM_MINS_IN_A_QUARTER) + 1
    }
    
    static func getCurrentPeriodIndex(at elapsedTime: TimeInterval = 0, withPeriod period: TimeInterval = Period.TimeInterval) -> Int? {
        return Int(elapsedTime) / Int(period)
    }
}
