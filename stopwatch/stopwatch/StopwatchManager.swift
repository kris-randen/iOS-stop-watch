//
//  StopwatchManager.swift
//  stopwatch
//
//  Created by Krishnaswami Rajendren on 12/11/23.
//

import Foundation

@MainActor
class StopwatchManager: ObservableObject {
    private var timer: Timer?
    private var wakeUpTime: Date?
    private var accumulatedTime: TimeInterval = 0
    private var periods: [Period] = []
    private var calendar = Calendar.current
    private(set) var userActivity: UserActivity
    private(set) var currentPeriodIndex: Int = 0
    private(set) var periodsLeft: Int = Constants.NUM_PERIODS_IN_A_DAY
    
    var onTimeUpdate: ((String, String) -> Void)?
    
    init() {
        calendar.timeZone = TimeZone.current
        userActivity = UserDefaults.standard.getActivity() ?? UserActivity()
        updateQuarters()
    }
    
    func start() {
        registerWakeUpTime()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task {
                [weak self] in
                await self?.updateTime()
            }
        }
    }
    
    func stop() {
        if let wakeUpTime = wakeUpTime {
            accumulatedTime += Date().timeIntervalSince(wakeUpTime)
        }
        timer?.invalidate()
        timer = nil
        self.wakeUpTime = nil
    }
    
    private func registerWakeUpTime() {
        wakeUpTime = Date.now
        updateUserActivity(wakeUpTime: wakeUpTime)
        updateQuarters()
    }
    
    private func updateUserActivity(wakeUpTime: Date? = nil, sleepTime: Date? = nil) {
        // Update wake-up and sleep times if recorded already
        if let wakeUpTime = wakeUpTime { userActivity.wakeUpTime = wakeUpTime }
        if let sleepTime = sleepTime { userActivity.sleepTime = sleepTime }
    }
    
    private func updateTime() async {
        guard let wakeUpTime = wakeUpTime else { return }
        let currentTime = Date()
        let elapsedTime = currentTime.timeIntervalSince(wakeUpTime) + accumulatedTime
        
        let hh = Int(elapsedTime / 3600)
        let mm = Int(elapsedTime / 60)
        let ss = Int(elapsedTime.truncatingRemainder(dividingBy: 60))
        
        let formattedTime = String(format: "%02d : %02d : %02d", hh, mm, ss)
        
        if isEndOfPeriod(at: elapsedTime) {
            currentPeriodIndex = Period.getCurrentPeriodIndex(at: elapsedTime, withPeriod: Period.TimeInterval) ?? 1
            periodsLeft = max(Constants.NUM_PERIODS_IN_A_DAY - currentPeriodIndex, 0)
        }
        
        let message = "Quarter \(currentPeriodIndex) just ended. \(periodsLeft) Left"
        
        await MainActor.run {
            self.onTimeUpdate?(formattedTime, message)
        }
    }
    
    private func isEndOfPeriod(at elapsedTime: TimeInterval, period: TimeInterval = Period.TimeInterval) -> Bool {
        return Int(elapsedTime) % Int(period) == 0
    }
    
    private func getQuarter(at index: Int?) -> Period? {
        guard let index = index else { return nil }
        return periods[index]
    }
    
    
    private func updateQuarters() {
        generateQuarters(from: userActivity.wakeUpTime)
    }
    
    func generateQuarters(from wakeUpTime: Date?) {
        periods.removeAll()
        guard let wakeUpTime = wakeUpTime else { return }
        
        // Calculate the start of the first quarter
        guard let firstQuarterStart = Period.getFirstPeriodStart(from: wakeUpTime, using: calendar) else { return  }
        
        // Generate all periods with period time intervals
        periods = Period.createAll(from: firstQuarterStart, using: calendar)
    }
}
