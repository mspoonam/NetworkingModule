//	
// Base Project 
//

import Foundation

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
                completion(self.map(data, response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    private func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        do {
            let items = try FeedItemMapper.map(data, response)
            return .success(items)
        } catch {
            return .failure(.invalidData)
        }
    }
}

