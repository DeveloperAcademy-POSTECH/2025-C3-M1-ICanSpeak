

import Foundation

struct TimeLogManager {
    static func saveLogs(_ logs: [TimeLog]) {
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: "TimeLogs")
        }
    }

    static func loadLogs() -> [TimeLog] {
        if let data = UserDefaults.standard.data(forKey: "TimeLogs"),
           let saved = try? JSONDecoder().decode([TimeLog].self, from: data) {
            return saved
        }
        return []
    }

    static func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: date)
    }
}
