//
//  HTTPClientTests.swift
//  GoPaddiAssessmentTests
//
//  Created by Oko-osi Korede Ibrahim on 27/02/2026.
//

import XCTest
@testable import GoPaddiAssessment

final class HTTPClientTests: XCTestCase {
    
    // MARK: - Mock URLSession
    
    class MockURLProtocol: URLProtocol {
        static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let handler = MockURLProtocol.requestHandler else {
                fatalError("Handler is not set")
            }
            
            do {
                let (response, data) = try handler(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
        
        override func stopLoading() {}
    }
    
    // MARK: - Test Setup
    
    var sut: HTTPClient!
    var mockSession: URLSession!
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: configuration)
        
        sut = HTTPClient(
            baseURL: URL(string: "https://test.api.com")!,
            session: mockSession
        )
    }
    
    override func tearDown() {
        sut = nil
        mockSession = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    // MARK: - API Request Tests
    
    func testAPIRequest_DefaultValues() {
        // Given
        struct TestRequest: APIRequest {
            typealias Response = [String: String]
            let path = "/test"
        }
        
        let request = TestRequest()
        
        // Then
        XCTAssertEqual(request.method, .GET, "Default method should be GET")
        XCTAssertNil(request.queryItems, "Default query items should be nil")
        XCTAssertNil(request.body, "Default body should be nil")
        XCTAssertTrue(request.headers.isEmpty, "Default headers should be empty")
    }
    
    // MARK: - Fetch Request Tests
    
    func testFetchRequest_PathConstruction() {
        // Given
        let request = FetchTripsRequest(status: nil)
        
        // Then
        XCTAssertEqual(request.path, "/trips")
        XCTAssertEqual(request.method, .GET)
    }
    
    func testFetchRequest_WithStatusQueryItem() {
        // Given
        let request = FetchTripsRequest(status: .planned)
        
        // Then
        XCTAssertNotNil(request.queryItems)
        XCTAssertEqual(request.queryItems?.first?.name, "status")
        XCTAssertEqual(request.queryItems?.first?.value, "Planned Trips")
    }
    
    func testFetchRequest_WithoutStatusQueryItem() {
        // Given
        let request = FetchTripsRequest(status: nil)
        
        // Then
        XCTAssertNil(request.queryItems)
    }
    
    // MARK: - Create Request Tests
    
    func testCreateRequest_Method() {
        // Given
        let request = CreateTripRequest(
            destination: "Paris",
            startDate: Date(),
            endDate: Date()
        )
        
        // Then
        XCTAssertEqual(request.method, .POST)
        XCTAssertEqual(request.path, "/trips")
        XCTAssertNotNil(request.body)
    }
    
    func testCreateRequest_BodyStructure() throws {
        // Given
        let destination = "Paris"
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 5, to: startDate)!
        
        let request = CreateTripRequest(
            destination: destination,
            startDate: startDate,
            endDate: endDate
        )
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(request.body as! CreateTripRequest.Body)
        let decoded = try JSONDecoder().decode(CreateTripRequest.Body.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.destination, destination)
        XCTAssertEqual(decoded.startDate.timeIntervalSince1970,
                      startDate.timeIntervalSince1970,
                      accuracy: 1.0)
        XCTAssertEqual(decoded.endDate.timeIntervalSince1970,
                      endDate.timeIntervalSince1970,
                      accuracy: 1.0)
    }
    
    // MARK: - HTTP Method Tests
    
    func testHTTPMethod_RawValues() {
        // Then
        XCTAssertEqual(HTTPMethod.GET.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.POST.rawValue, "POST")
        XCTAssertEqual(HTTPMethod.PUT.rawValue, "PUT")
        XCTAssertEqual(HTTPMethod.DELETE.rawValue, "DELETE")
        XCTAssertEqual(HTTPMethod.PATCH.rawValue, "PATCH")
    }
    
    // MARK: - Success Response Tests
    
    func testHTTPClient_SuccessfulResponse() async throws {
        // Given
        struct TestResponse: Codable {
            let message: String
        }
        
        struct TestRequest: APIRequest {
            typealias Response = TestResponse
            let path = "/test"
        }
        
        let expectedResponse = TestResponse(message: "Success")
        let responseData = try JSONEncoder().encode(expectedResponse)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, responseData)
        }
        
        // When
        let response = try await sut.send(TestRequest())
        
        // Then
        XCTAssertEqual(response.message, "Success")
    }
    
    // MARK: - Error Response Tests
    
    func testHTTPClient_ServerError() async {
        // Given
        struct TestRequest: APIRequest {
            typealias Response = [String: String]
            let path = "/test"
        }
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        
        // When & Then
        do {
            _ = try await sut.send(TestRequest())
            XCTFail("Should throw server error")
        } catch let error as NetworkError {
            if case .serverError(let code) = error {
                XCTAssertEqual(code, 404)
            } else {
                XCTFail("Should be server error")
            }
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testHTTPClient_DecodingError() async {
        // Given
        struct TestResponse: Codable {
            let id: Int
        }
        
        struct TestRequest: APIRequest {
            typealias Response = TestResponse
            let path = "/test"
        }
        
        let invalidData = "invalid json".data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, invalidData)
        }
        
        // When & Then
        do {
            _ = try await sut.send(TestRequest())
            XCTFail("Should throw decoding error")
        } catch let error as NetworkError {
            if case .decodingError = error {
                // Success
            } else {
                XCTFail("Should be decoding error")
            }
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    // MARK: - Request Construction Tests
    
    func testHTTPClient_URLConstruction() async throws {
        // Given
        struct TestRequest: APIRequest {
            typealias Response = [String: String]
            let path = "/trips"
            var queryItems: [URLQueryItem]? { [URLQueryItem(name: "status", value: "planned")] }
        }
        
        var capturedRequest: URLRequest?
        
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = try JSONEncoder().encode([String: String]())
            return (response, data)
        }
        
        // When
        _ = try await sut.send(TestRequest())
        
        // Then
        XCTAssertNotNil(capturedRequest)
        let urlString = capturedRequest?.url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("/trips"), "URL should contain /trips. Actual URL: \(urlString)")
        XCTAssertTrue(urlString.contains("status=planned"), "URL should contain status=planned. Actual URL: \(urlString)")
    }
    
    func testHTTPClient_HeadersSet() async throws {
        // Given
        struct TestRequest: APIRequest {
            typealias Response = [String: String]
            let path = "/test"
            let headers = ["Authorization": "Bearer token123"]
        }
        
        var capturedRequest: URLRequest?
        
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = try JSONEncoder().encode([String: String]())
            return (response, data)
        }
        
        // When
        _ = try await sut.send(TestRequest())
        
        // Then
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "Authorization"),
                      "Bearer token123")
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "Content-Type"),
                      "application/json")
    }
}
