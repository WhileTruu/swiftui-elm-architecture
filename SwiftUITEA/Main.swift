import Combine
import SwiftUI

// MARK: MODEL

struct Model {
    let repos: [Repo]
    let query: String
}

extension Model {
    init() {
        self.repos = []
        self.query = "Elm"
    }
}

extension Model {
    func copy(searchResult: [Repo]? = nil, query: String? = nil) -> Model {
        Model(
            repos: searchResult ?? self.repos,
            query: query ?? self.query
        )
    }
}

// MARK: UPDATE

enum Msg {
    case searched
    case gotSearchResult(repos: [Repo])
    case changedQuery(query: String)
}

func update(model: Model, msg: Msg) -> (Model, AnyPublisher<Msg, Never>) {
    switch msg {
    case let .gotSearchResult(repos):
        return (
            model.copy(searchResult: repos),
            Empty().eraseToAnyPublisher()
        )

    case .searched:
        return (
            model,
            RepoService
                .searchPublisher(matching: model.query)
                .replaceError(with: [])
                .map { repos in
                    Msg.gotSearchResult(repos: repos)
                }
                .eraseToAnyPublisher()
        )

    case let .changedQuery(query):
        return (
            model.copy(query: query),
            Empty().eraseToAnyPublisher()
        )
    }
}

// MARK: VIEW

struct MainView: View {
    @EnvironmentObject var app: Store<Model, Msg>

    var body: some View {
        let model = app.model
        let send = app.send

        let query = Binding<String>(
            get: { model.query },
            set: { send(.changedQuery(query: $0)) }
        )

        return NavigationView {
            List {
                TextField(
                    "Type something",
                    text: query,
                    onCommit: { send(.searched) }
                )

                if model.repos.isEmpty {
                    Text("Loading...")
                } else {
                    ForEach(model.repos) { repo in
                        RepoRow(repo: repo)
                    }
                }
            }
                .navigationBarTitle(Text("Search"))
                .onAppear {
                    send(.searched)
                }
        }
    }
}

struct RepoRow: View {
    let repo: Repo

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(repo.name)
                    .font(.headline)
                Text(repo.description ?? "")
                    .font(.subheadline)
            }
        }
    }
}



