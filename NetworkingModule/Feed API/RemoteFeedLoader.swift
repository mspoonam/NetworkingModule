//	
// Base Project 
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

// Dont wanna allow subclassing
public final class RemoteFeedLoader {
    
    // arrange this order based on the init
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(RemoteFeedLoader.Error)
    }
    
    public init(url: URL ,client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    // MARK: there is another interesting thing - how the switch changes from case .success: to case case let .success(data, response)
    
    public func load(completion: @escaping (RemoteFeedLoader.Result)->Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                if let json = try? JSONSerialization.jsonObject(with: data) {
                    completion(.success([]))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
