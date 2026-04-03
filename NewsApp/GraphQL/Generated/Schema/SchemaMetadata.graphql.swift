// @generated
// This file was automatically generated and should not be edited.

import Apollo

protocol NewsAPI_SelectionSet: Apollo.SelectionSet & Apollo.RootSelectionSet
where Schema == NewsAPI.SchemaMetadata {}

protocol NewsAPI_InlineFragment: Apollo.SelectionSet & Apollo.InlineFragment
where Schema == NewsAPI.SchemaMetadata {}

protocol NewsAPI_MutableSelectionSet: Apollo.MutableRootSelectionSet
where Schema == NewsAPI.SchemaMetadata {}

protocol NewsAPI_MutableInlineFragment: Apollo.MutableSelectionSet & Apollo.InlineFragment
where Schema == NewsAPI.SchemaMetadata {}

extension NewsAPI {
  typealias SelectionSet = NewsAPI_SelectionSet

  typealias InlineFragment = NewsAPI_InlineFragment

  typealias MutableSelectionSet = NewsAPI_MutableSelectionSet

  typealias MutableInlineFragment = NewsAPI_MutableInlineFragment

  enum SchemaMetadata: Apollo.SchemaMetadata {
    static let configuration: any Apollo.SchemaConfiguration.Type = SchemaConfiguration.self

    static func objectType(forTypename typename: String) -> Apollo.Object? {
      switch typename {
      case "NewsArticle": return NewsAPI.Objects.NewsArticle
      case "Query": return NewsAPI.Objects.Query
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}