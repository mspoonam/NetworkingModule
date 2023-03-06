//	
// Base Project 
//

import Foundation

internal class FeedItemMapper {
    static var OK_200: Int { return 200 }
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else { throw RemoteFeedLoader.Error.invalidData }
        let rootItem = try JSONDecoder().decode(ItemRoot.self, from: data)
        return rootItem.items.map {$0.ele}
    }
    private struct ItemRoot: Decodable {
        let items: [Item]
    }
    
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var ele: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
        
    }

}

