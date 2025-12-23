import Foundation

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public protocol NetworkClient {
    func request(
        _ request: Request
    ) async throws(APIError) -> PlainNetworkResponse

    func requestModel<T: Decodable>(
        _ request: Request,
        type: T.Type,
        decoder: JSONDecoder
    ) async throws(APIError) -> NetworkResponse<T>
}

public extension NetworkClient {
    func requestModel<T: Decodable>(
        _ request: Request,
        type: T.Type
    ) async throws(APIError) -> NetworkResponse<T> {
        try await requestModel(
            request,
            type: type,
            decoder: JSONCoderFactory.makeAPIDecoder()
        )
    }

    func requestModel<T: Decodable>(
        builder requestBuilder: RequestBuilder,
        type: T.Type,
        decoder: JSONDecoder = JSONCoderFactory.makeAPIDecoder()
    ) async throws(APIError) -> NetworkResponse<T> {
        let request: Request
        do {
            request = try requestBuilder.build()
        } catch {
            throw .requiestBuilder(error)
        }

        return try await requestModel(
            request,
            type: type,
            decoder: decoder
        )
    }
}

public class APIClient: NetworkClient {
    private let session: URLSession

    public init(
        session: URLSession = .shared,
    ) {
        self.session = session
    }

    public func request(
        _ request: Request
    ) async throws(APIError) -> PlainNetworkResponse {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body

        request.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        do {
            let (data, urlResponse) = try await session.data(for: urlRequest)
            let statusCode = (urlResponse as! HTTPURLResponse).statusCode

            let response = PlainNetworkResponse(
                body: data,
                statusCode: .init(code: statusCode)
            )

            return response
        } catch {
            throw APIError.networkError(error)
        }
    }

    public func requestModel<T: Decodable>(
        _ request: Request,
        type: T.Type,
        decoder: JSONDecoder
    ) async throws(APIError) -> NetworkResponse<T> {
        let result = try await self.request(request) as PlainNetworkResponse
        guard let data = result.body else {
            throw APIError.invalidResponse
        }

        do {
            let model = try decoder.decode(T.self, from: data)
            return .init(
                body: model,
                statusCode: result.statusCode
            )
        } catch {
            throw .decoding(
                ExtendedDecodingError(
                    error: error
                    ,data: data
                )
            )
        }
    }
}
