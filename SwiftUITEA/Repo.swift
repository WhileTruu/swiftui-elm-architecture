import SwiftUI
import Combine

struct Repo: Decodable, Identifiable {
    var id: Int
    let owner: Owner
    let name: String
    let description: String?

    struct Owner: Decodable {
        let avatar: URL

        enum CodingKeys: String, CodingKey {
            case avatar = "avatar_url"
        }
    }
}

extension Repo {
    private struct ReposResponse: Decodable {
        let items: [Repo]
    }
    
    static func fetch(matching query: String) -> AnyPublisher<[Repo], Error> {
        let session = URLSession(configuration: .ephemeral)
        let decoder = JSONDecoder()

        guard
            var urlComponents = URLComponents(string: "https://api.github.com/search/repositories")
            else { preconditionFailure("Can't create url components...") }

        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query)
        ]

        guard
            let url = urlComponents.url
            else { preconditionFailure("Can't create url from url components...") }

        return session
            .dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: ReposResponse.self, decoder: decoder)
            .map { $0.items }
            .eraseToAnyPublisher()
    }
}
