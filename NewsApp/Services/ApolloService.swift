//
//  ApolloService.swift
//  NewsApp
//
//  Apollo iOS 客户端配置
//  - 生产环境：连接真实 GraphQL 服务器
//  - 开发环境：使用 MockNetworkTransport 返回本地数据
//

import Foundation
import Apollo

final class ApolloService {

    static let shared = ApolloService()

    /// 切换为真实 GraphQL 端点后，替换此 URL
    private static let graphQLEndpoint = "https://your-api.example.com/graphql"

    /// 是否使用 Mock 数据（无真实 GraphQL 服务器时设为 true）
    static let useMockData = true

    let client: ApolloClient

    private init() {
        if ApolloService.useMockData {
            // Mock 模式：使用自定义 NetworkTransport 返回本地 JSON
            let transport = MockNewsTransport()
            let store = ApolloStore()
            self.client = ApolloClient(networkTransport: transport, store: store)
        } else {
            // 生产模式：连接真实 GraphQL 服务器
            let url = URL(string: ApolloService.graphQLEndpoint)!
            self.client = ApolloClient(url: url)
        }
    }
}

// MARK: - Mock Network Transport

/// 模拟 GraphQL 服务器响应，返回本地新闻数据
/// 当你接入真实 GraphQL 后端后，可将 useMockData 设为 false，此类不再被使用
final class MockNewsTransport: NetworkTransport {

    func send<Operation: GraphQLOperation>(
        operation: Operation,
        cachePolicy: CachePolicy,
        contextIdentifier: UUID?,
        context: (any RequestContext)?,
        callbackQueue: DispatchQueue,
        completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void
    ) -> any Cancellable {

        callbackQueue.async {
            let operationName = Operation.operationName

            if operationName == "NewsFeed" {
                let json = MockNewsData.newsFeedJSON()
                self.parseAndReturn(json: json, operation: operation, completionHandler: completionHandler)
            } else if operationName == "Article" {
                // 从 variables 中取 id
                let json = MockNewsData.articleJSON(id: "1")
                self.parseAndReturn(json: json, operation: operation, completionHandler: completionHandler)
            } else {
                completionHandler(.failure(MockError.unknownOperation(operationName)))
            }
        }

        return EmptyCancellable()
    }

    private func parseAndReturn<Operation: GraphQLOperation>(
        json: [String: Any],
        operation: Operation,
        completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void
    ) {
        do {
            let data = try JSONSerialization.data(withJSONObject: json)
            let body = try JSONSerializationFormat.deserialize(data: data) as! JSONObject
            let response = GraphQLResponse(operation: operation, body: body)
            let (result, _) = try response.parseResult()
            completionHandler(.success(result))
        } catch {
            completionHandler(.failure(error))
        }
    }

    enum MockError: Error, LocalizedError {
        case unknownOperation(String)
        var errorDescription: String? {
            switch self {
            case .unknownOperation(let name):
                return "Mock transport: unknown operation '\(name)'"
            }
        }
    }
}

// MARK: - Empty Cancellable

private final class EmptyCancellable: Cancellable {
    func cancel() {}
}
