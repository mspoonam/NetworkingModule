//	
// Base Project 
//

import Foundation

internal class FeedItemMapper {
    static var OK_200: Int { return 200 }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200,
              let rootItem = try? JSONDecoder().decode(ItemRoot.self, from: data) else {
            return .failure(.invalidData)
        }
        let items = rootItem.items.map {$0.ele}
        return .success(items)
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

