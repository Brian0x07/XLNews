// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension NewsAPI {
  class ArticleQuery: GraphQLQuery {
    static let operationName: String = "Article"
    static let operationDocument: Apollo.OperationDocument = .init(
      definition: .init(
        #"query Article($id: ID!) { article(id: $id) { __typename id title summary body imageUrl source publishedAt category } }"#
      ))

    public var id: ID

    public init(id: ID) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: NewsAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any Apollo.ParentType { NewsAPI.Objects.Query }
      static var __selections: [Apollo.Selection] { [
        .field("article", Article?.self, arguments: ["id": .variable("id")]),
      ] }

      /// 获取单篇文章详情
      var article: Article? { __data["article"] }

      /// Article
      ///
      /// Parent Type: `NewsArticle`
      struct Article: NewsAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any Apollo.ParentType { NewsAPI.Objects.NewsArticle }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("id", NewsAPI.ID.self),
          .field("title", String.self),
          .field("summary", String.self),
          .field("body", String.self),
          .field("imageUrl", String.self),
          .field("source", String.self),
          .field("publishedAt", String.self),
          .field("category", String.self),
        ] }

        var id: NewsAPI.ID { __data["id"] }
        var title: String { __data["title"] }
        var summary: String { __data["summary"] }
        var body: String { __data["body"] }
        var imageUrl: String { __data["imageUrl"] }
        var source: String { __data["source"] }
        var publishedAt: String { __data["publishedAt"] }
        var category: String { __data["category"] }
      }
    }
  }

}