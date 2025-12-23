import Foundation

public enum JSONCoderFactory {
    /// Creates a JSONDecoder configured for API responses
    /// - Dates are decoded from ISO 8601 format, with or without timezone
    ///   (e.g., "2025-11-15T17:30:00Z" or "2025-11-15T17:30:00")
    public static func makeAPIDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try ISO8601 with timezone first
            if let date = ISO8601DateFormatter().date(from: dateString) {
                return date
            }

            // Try ISO8601 without timezone (assume UTC)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date
            }

            // Fallback: try without fractional seconds
            let basicFormatter = DateFormatter()
            basicFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            basicFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            basicFormatter.locale = Locale(identifier: "en_US_POSIX")

            if let date = basicFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected date string to be ISO8601-formatted."
            )
        }
        return decoder
    }

    /// Creates a JSONEncoder configured for API requests
    /// - Dates are encoded to ISO 8601 format without timezone (e.g., "2025-11-15T17:30:00")
    /// - This matches Java LocalDateTime format expected by the server
    public static func makeAPIEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            let dateString = formatter.string(from: date)
            try container.encode(dateString)
        }
        return encoder
    }
}
