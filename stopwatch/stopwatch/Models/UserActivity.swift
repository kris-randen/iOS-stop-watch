//
//  UserActivity.swift
//  stopwatch
//
//  Created by Krishnaswami Rajendren on 12/11/23.
//

import Foundation

struct UserActivity: Codable {
    var wakeUpTime: Date? = Date.now
    var sleepTime: Date?
}

extension UserDefaults {
    private var activityKey: String { "userActivity" }
    
    func saveActivity(_ activity: UserActivity) {
        guard let encoded = try? JSONEncoder().encode(activity) else { return }
        set(encoded, forKey: activityKey)
    }
    
    func getActivity() -> UserActivity? {
        guard let data = object(forKey: activityKey) as? Data else { return nil }
        return try? JSONDecoder().decode(UserActivity.self, from: data)
    }
}
