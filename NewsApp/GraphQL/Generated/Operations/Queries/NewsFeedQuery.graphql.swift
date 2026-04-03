// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension NewsAPI {
  class NewsFeedQuery: GraphQLQuery {
    static let operationName: String = "NewsFeed"
    static let operationDocument: Apollo.OperationDocument = .init(
      definition: .init(
        #"query NewsFeed($category: String!, $limit: Int = 20) { newsFeed(category: $category, limit: $limit) { __typename id title summary body imageUrl source publishedAt category } }"#
      ))

    public var category: String
    public var limit: GraphQLNullable<Int>

    public init(
      category: String,
      limit: GraphQLNullable<Int> = 20
    ) {
      self.category = category
      self.limit = limit
    }

    public var __variables: Variables? { [
      "category": category,
      "limit": limit
    ] }

    struct Data: NewsAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any Apollo.ParentType { NewsAPI.Objects.Query }
      static var __selections: [Apollo.Selection] { [
        .field("newsFeed", [NewsFeed].self, arguments: [
          "category": .variable("category"),
          "limit": .variable("limit")
        ]),
      ] }

      /// 获取新闻列表，按分类筛选
      var newsFeed: [NewsFeed] { __data["newsFeed"] }

      /// NewsFeed
      ///
      /// Parent Type: `NewsArticle`
      struct NewsFeed: NewsAPI.SelectionSet {
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