//
// Base Project
//

import XCTest
import NetworkingModule

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesnotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let (sut , client) = makeSUT()
        sut.load{ _ in }
        XCTAssertNotNil(client.requestedURLs)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut , client) = makeSUT(url: url)
        sut.load{ _ in }
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut , client) = makeSUT(url: url)
        sut.load{ _ in }
        sut.load{ _ in }
        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut , client) = makeSUT()
        
        // Arrange
        var capturedError =  [RemoteFeedLoader.Error]()
        
        // Arrange
        sut.load { error in
            // capturing data
            capturedError.append(error)
        }
        
        // this is stubbing
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        // Assert
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut , client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            // Arrange
            var capturedError =  [RemoteFeedLoader.Error]()
            // Arrange
            sut.load {
                capturedError.append($0)
            }
            // capturing values
            client.complete(withStatusCode: code, at: index)
            // Assert
            XCTAssertEqual(capturedError, [.invalidData])
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut , client) = makeSUT()
        
        expect(sut, toCompleteWithError: .invalidData, when: {
            let invalidJSON = Data.init("invalid data".utf8)
            // capturing values
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    
    // MARK:- Helpers
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWithError error: RemoteFeedLoader.Error,
                        when action: ()->Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        var capturedError =  [RemoteFeedLoader.Error]()
        // Arrange
        sut.load { capturedError.append($0) }
        let invalidJSON = Data.init("invalid data".utf8)
        // capturing values
        action()
        // Assert
        XCTAssertEqual(capturedError, [error], file: file, line: line)
    }
    
    class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var messages = [(url: URL, completion: (HTTPClientResult)->Void)]()
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
            requestedURLs.append(url)
        }
        // TODO: Doubt - what completions[index](error) does
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int,data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}

