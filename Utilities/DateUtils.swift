import Foundation

enum DateUtils {
    static func startOfDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    static func endOfDay(_ date: Date) -> Date {
        guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay(date)) else {
            return date
        }
        return nextDay
    }

    static func dayInterval(for date: Date) -> DateInterval {
        DateInterval(start: startOfDay(date), end: endOfDay(date))
    }

    static func last7Days(endingOn date: Date) -> [Date] {
        let start = startOfDay(date)
        return (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -offset, to: start)
        }.reversed()
    }
}
