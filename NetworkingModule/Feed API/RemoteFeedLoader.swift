//	
// Base Project 
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
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
    
    public init(url: URL ,client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (RemoteFeedLoader.Error)->Void) {
        client.get(from: url) { error, response in
            if  response != nil {
                completion(.invalidData)
            } else {
                completion(.connectivity)
            }
        }
    }
}
