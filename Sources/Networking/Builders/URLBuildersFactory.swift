import Foundation

@MainActor
public final class URLBuildersFactory {
    private var baseURL: String

    private init(
        baseURL: String
    ) {
        self.baseURL = baseURL
    }

    public func setBaseURL(_ baseURL: String) {
        self.baseURL = baseURL
    }

    public func base() -> URLBuilder {
        URL.builder
            .baseURL(baseURL)
    }
}
