//	
// Base Project 
//

import Foundation

// Dont wanna allow subclassing
public final class RemoteFeedLoader: FeedLoader {
    
    // arrange this order based on the init
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult<Error>
   
    public init(url: URL ,client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    // MARK: there is another interesting thing - how the switch changes from case .success: to case case let .success(data, response)
    
    public func load(completion: @escaping (Result)->Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else {
                return
            }
            
            switch result {
            case let .success(data, response):
                completion(FeedItemMapper.map(data, response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

