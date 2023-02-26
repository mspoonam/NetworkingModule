//	
// Base Project 
//

import Foundation

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    init(url: URL ,client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}
