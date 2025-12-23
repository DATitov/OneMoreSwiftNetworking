import Foundation

public final class RequestBuildersFactory {
    public let urlBuildersFactory: URLBuildersFactory

    public init(
        urlBuildersFactory: URLBuildersFactory
    ) {
        self.urlBuildersFactory = urlBuildersFactory
    }
}
