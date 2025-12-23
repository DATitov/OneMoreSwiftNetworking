import Foundation

public struct Request: Sendable {
    public let url: URL
    public let body: Data?
    public let headers: [String: String]?
    public let method: HTTPMethod
    
    public init(url: URL, body: Data?, headers: [String: String]?, method: HTTPMethod) {
        self.url = url
        self.body = body
        self.headers = headers
        self.method = method
    }
}

extension Request {
    public static var builder: RequestBuilder { RequestBuilder() }
}

public struct RequestBuilder: Sendable {
    public enum Failure: Error, Sendable {
        public enum Field: Sendable {
            case url, method
        }
        case missing(Field)
        case encoding(EncodingError)
        case urlBuilding(URLBuilder.Failure)
    }

    public enum URLSource: Sendable {
        case url(URL)
        case urlBuilder(URLBuilder)
    }

    public enum Body: Sendable {
        case data(Data)
        case encodable(
            any Encodable & Sendable,
            encoder: JSONEncoder = JSONCoderFactory.makeAPIEncoder()
        )
    }

    public var urlSource: URLSource?
    public var body: Body?
    public var headers: [String: String]?
    public var method: HTTPMethod?

    public init() {
        self.urlSource = nil
        self.body = nil
        self.headers = nil
        self.method = nil
    }

    public func url(_ url: URL) -> Self {
        var builder = self
        builder.urlSource = .url(url)
        return builder
    }

    public func url(_ urlBuilder: URLBuilder) -> Self {
        var builder = self
        builder.urlSource = .urlBuilder(urlBuilder)
        return builder
    }
    
    public func method(_ method: HTTPMethod) -> Self {
        var builder = self
        builder.method = method
        return builder
    }
    
    public func body(_ body: Body) -> Self {
        var builder = self
        builder.body = body
        return builder
    }
    
    public func headers(_ headers: [String: String]) -> Self {
        var builder = self
        builder.headers = headers
        return builder
    }
    
    public func encodable(
        _ encodable: any Encodable & Sendable,
        encoder: JSONEncoder = JSONCoderFactory.makeAPIEncoder()
    ) -> Self {
        var builder = self
        builder.body = .encodable(encodable, encoder: encoder)
        return builder
    }

    public func build() throws (Failure) -> Request {
        guard let urlSource else { throw .missing(.url) }
        guard let method else { throw .missing(.method) }

        let url: URL
        switch urlSource {
        case .url(let directURL):
            url = directURL
        case .urlBuilder(let builder):
            do {
                url = try builder.build()
            } catch let error as URLBuilder.Failure {
                throw .urlBuilding(error)
            } catch {
                fatalError("Unexpected error from URLBuilder: \(error)")
            }
        }

        let body: Data?
        var finalHeaders = headers ?? [:]

        switch self.body {
        case .data(let data):
            body = data
        case let .encodable(encodable, encoder):
            do {
                body = try encoder.encode(encodable)
                // Debug: Print the JSON being sent
                if let jsonString = String(data: body!, encoding: .utf8) {
                    print("DEBUG: Request JSON for \(url.path):\n\(jsonString)")
                }
                // Automatically add Content-Type header for JSON encoded bodies
                if finalHeaders["Content-Type"] == nil {
                    finalHeaders["Content-Type"] = "application/json"
                }
            } catch {
                throw .encoding(error as! EncodingError)
            }
        case .none:
            body = nil
        }

        return .init(
            url: url,
            body: body,
            headers: finalHeaders.isEmpty ? nil : finalHeaders,
            method: method
        )
    }
}
