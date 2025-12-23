import Foundation

public struct StatusCode: CustomStringConvertible, Sendable, ExpressibleByIntegerLiteral {
    public let code: Int
    
    public init(code: Int) {
        self.code = code
    }
    
    public init(integerLiteral value: Int) {
        self.code = value
    }
    
    // 2xx Success
    public static let ok = StatusCode(code: 200)
    public static let created = StatusCode(code: 201)
    public static let accepted = StatusCode(code: 202)
    public static let noContent = StatusCode(code: 204)
    
    // 4xx Client Error
    public static let badRequest = StatusCode(code: 400)
    public static let unauthorized = StatusCode(code: 401)
    public static let forbidden = StatusCode(code: 403)
    public static let notFound = StatusCode(code: 404)
    public static let methodNotAllowed = StatusCode(code: 405)
    public static let conflict = StatusCode(code: 409)
    public static let unprocessableEntity = StatusCode(code: 422)
    
    // 5xx Server Error
    public static let internalServerError = StatusCode(code: 500)
    public static let badGateway = StatusCode(code: 502)
    public static let serviceUnavailable = StatusCode(code: 503)
    
    public var description: String {
        let message: String
        switch code {
        case 200: message = "Ok"
        case 201: message = "Created"
        case 202: message = "Accepted"
        case 204: message = "No Content"
        case 400: message = "Bad Request"
        case 401: message = "Unauthorized"
        case 403: message = "Forbidden"
        case 404: message = "Not Found"
        case 405: message = "Method Not Allowed"
        case 409: message = "Conflict"
        case 422: message = "Unprocessable Entity"
        case 500: message = "Internal Server Error"
        case 502: message = "Bad Gateway"
        case 503: message = "Service Unavailable"
        default: message = "Unknown"
        }
        return "\(code), \(message)"
    }
}

