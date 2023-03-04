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
        sut.load()
        XCTAssertNotNil(client.requestedURLs)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut , client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut , client) = makeSUT(url: url)
        sut.load()
        sut.load()
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
    
    // MARK:- Helpers
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var messages = [(url: URL, completion: (Error)->Void)]()
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            messages.append((url, completion))
            requestedURLs.append(url)
        }
        // TODO: Doubt - what completions[index](error) does
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error)
        }
    }
}

