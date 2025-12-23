import Foundation

public typealias PlainNetworkResponse = NetworkResponse<Data?>

public struct NetworkResponse<Body> {
    public let body: Body
    public let statusCode: StatusCode
    
    public init(
        body: Body,
        statusCode: StatusCode
    ) {
        self.body = body
        self.statusCode = statusCode
    }
}

extension NetworkResponse: Sendable where Body: Sendable { }
