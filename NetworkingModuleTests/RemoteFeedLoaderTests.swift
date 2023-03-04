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
        
        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            // this is stubbing
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
        
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut , client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                // capturing values
                client.complete(withStatusCode: code, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut , client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJSON = Data.init("invalid data".utf8)
            // capturing values
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversEmptyErrorOn200HTTPResponse() {
        let (sut , client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyJSON = Data.init("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyJSON)
        })
        
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut , client) = makeSUT()
        
        let item1 = FeedItem(id: UUID(), description: nil, location: nil, imageURL: URL(string:"http://a.com")!)
        let item1Json = [
            "id": item1.id.uuidString,
            "image": item1.imageURL.absoluteString
        ]
        let item2 = FeedItem(id: UUID(), description: "a description", location: "a location", imageURL: URL(string: "http://b.com")!)
        let item2Json = [
            "id": item2.id.uuidString,
            "description": item2.description,
            "location": item2.location,
            "image": item2.imageURL.absoluteString
        ]
        let itemJson = [
            "items": [item1Json, item2Json]
        ]
        
        expect(sut, toCompleteWith: .success([item1, item2]), when: {
            
            let json = try! JSONSerialization.data(withJSONObject: itemJson)
            client.complete(withStatusCode: 200, data: json)
        })
        
    }
    
    // MARK:- Helpers
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWith result: RemoteFeedLoader.Result,
                        when action: ()->Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        var capturedResult =  [RemoteFeedLoader.Result]()
        // Arrange
        sut.load { capturedResult.append($0) }
        // capturing values
        action()
        // Assert
        XCTAssertEqual(capturedResult, [result], file: file, line: line)
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

