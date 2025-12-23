import Foundation

public struct ExtendedDecodingError {
    public let error: Error
#if DEBUG
    public let rawString: String
#endif

    public var decodingError: DecodingError? {
        error as? DecodingError
    }

    init(
        error: Error
        ,data: Data
    ) {
        self.error = error
#if DEBUG
        self.rawString = String(data: data, encoding: .utf8)!
#endif
    }

#if DEBUG
    init(
        error: Error
        ,rawString: String
    ) {
        self.error = error
        self.rawString = rawString
    }
#endif

#if !DEBUG
    init(
        error: Error
    ) {
        self.error = error
    }
#endif
}

extension ExtendedDecodingError: Sendable { }
