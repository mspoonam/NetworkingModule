//	
// Base Project 
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}

// Dont wanna allow subclassing
public final class RemoteFeedLoader {
    
    // arrange this order based on the init
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL ,client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.get(from: url)
    }
}
