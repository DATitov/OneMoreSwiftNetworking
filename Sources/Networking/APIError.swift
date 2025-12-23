import Foundation

public enum APIError {
    case invalidURL
    case invalidResponse
    case decoding(ExtendedDecodingError)
    case networkError(Error)
    case statusCode(StatusCode)
    case requiestBuilder(RequestBuilder.Failure)
}

extension APIError: Error { }
extension APIError: Sendable { }
