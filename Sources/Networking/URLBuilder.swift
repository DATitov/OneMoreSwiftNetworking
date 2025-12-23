import Foundation

public struct URLBuilder: Sendable {
    public enum Failure: Error, Sendable {
        public enum Field: Sendable {
            case baseURL
        }
        case missing(Field)
        case invalidURL(String)
    }

    private var baseURL: String?
    private var path: String?
    private var queryItems: [URLQueryItem]

    public enum Change {
        case queryItem(name: String, value: String?)
    }

    public init() {
        self.baseURL = nil
        self.path = nil
        self.queryItems = []
    }

    public func `if`(
        _ condition: @autoclosure () -> Bool,
        _ change: Change
    ) -> Self {
        guard condition() else {
            return self
        }
        switch change {
        case let .queryItem(name, value):
            return queryItem(name: name, value: value)
        }
    }

    public func baseURL(_ baseURL: String) -> Self {
        var builder = self
        builder.baseURL = baseURL
        return builder
    }

    public func path(_ path: String) -> Self {
        var builder = self
        builder.path = path
        return builder
    }

    public func queryItem(name: String, value: String?) -> Self {
        var builder = self
        builder.queryItems.append(URLQueryItem(name: name, value: value))
        return builder
    }

    public func queryItems(_ items: [URLQueryItem]) -> Self {
        var builder = self
        builder.queryItems.append(contentsOf: items)
        return builder
    }

    public func build() throws -> URL {
        guard let baseURL else {
            throw Failure.missing(.baseURL)
        }

        guard var components = URLComponents(string: baseURL) else {
            throw Failure.invalidURL(baseURL)
        }

        if let path {
            // Ensure path starts with / if not empty
            if !path.isEmpty && !path.hasPrefix("/") {
                components.path = "/" + path
            } else {
                components.path = path
            }
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw Failure.invalidURL("\(baseURL)\(path ?? "")")
        }

        return url
    }
}

extension URL {
    public static var builder: URLBuilder { URLBuilder() }
}
