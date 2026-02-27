//
//  HTTPClient.swift
//  GoPaddiAssessment
//
//  Created by Oko-osi Korede Ibrahim on 26/02/2026.
//

// MARK: - Network/HTTPClient.swift

import Foundation

// MARK: - HTTP Method
enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, PATCH
}

// MARK: - API Request Protocol
protocol APIRequest {
    associatedtype Response: Decodable
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Encodable? { get }
    var headers: [String: String] { get }
}

extension APIRequest {
    var method: HTTPMethod { .GET }
    var queryItems: [URLQueryItem]? { nil }
    var body: Encodable? { nil }
    var headers: [String: String] { [:] }
}

// MARK: - HTTP Client Protocol
protocol HTTPClientProtocol {
    func send<R: APIRequest>(_ request: R) async throws -> R.Response
}

// MARK: - Live URLSession Client
final class HTTPClient: HTTPClientProtocol {
    static let shared = HTTPClient()

    private let session: URLSession
    private let baseURL: URL
    private let decoder: JSONDecoder

    init(
        baseURL: URL = URL(string: "https://api.tripplanner.example.com/v1")!,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func send<R: APIRequest>(_ request: R) async throws -> R.Response {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(request.path), resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }

        components.queryItems = request.queryItems

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }

        if let body = request.body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            urlRequest.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await session.data(for: urlRequest)

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.unknown(URLError(.badServerResponse))
        }

        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.serverError(http.statusCode)
        }

        do {
            return try decoder.decode(R.Response.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
