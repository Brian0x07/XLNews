//
//  NewsDataBridge.swift
//  NewsApp
//
//  RN 原生模块 — 通过 Apollo iOS 获取新闻数据并返回给 RN
//
//  RN 侧调用示例:
//    const data = await NativeModules.NewsDataBridge.fetchNewsFeed("tech");
//

import Foundation
import Apollo
import React

@objc(NewsDataBridge)
final class NewsDataBridge: NSObject {

    @objc static func requiresMainQueueSetup() -> Bool {
        return false
    }

    /// 获取新闻列表
    /// - Parameters:
    ///   - category: 新闻分类 (tech, medical, science, world, business, sports, trending)
    ///   - resolve: Promise resolve — 返回 [NewsItem] 数组
    ///   - reject: Promise reject
    @objc func fetchNewsFeed(
        _ category: String,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        let query = NewsAPI.NewsFeedQuery(category: category)

        ApolloService.shared.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely) { result in
            switch result {
            case .success(let graphQLResult):
                if let errors = graphQLResult.errors, !errors.isEmpty {
                    let message = errors.map { $0.localizedDescription }.joined(separator: ", ")
                    reject("GRAPHQL_ERROR", message, nil)
                    return
                }

                guard let articles = graphQLResult.data?.newsFeed else {
                    resolve([])
                    return
                }

                // 转换为 RN 可用的字典数组
                let items: [[String: Any]] = articles.map { article in
                    [
                        "id": article.id,
                        "title": article.title,
                        "summary": article.summary,
                        "body": article.body,
                        "image": article.imageUrl,
                        "source": article.source,
                        "time": article.publishedAt,
                        "category": article.category
                    ]
                }
                resolve(items)

            case .failure(let error):
                reject("NETWORK_ERROR", error.localizedDescription, error)
            }
        }
    }

    /// 获取单篇文章详情
    @objc func fetchArticle(
        _ articleId: String,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        let query = NewsAPI.ArticleQuery(id: articleId)

        ApolloService.shared.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely) { result in
            switch result {
            case .success(let graphQLResult):
                if let errors = graphQLResult.errors, !errors.isEmpty {
                    let message = errors.map { $0.localizedDescription }.joined(separator: ", ")
                    reject("GRAPHQL_ERROR", message, nil)
                    return
                }

                guard let article = graphQLResult.data?.article else {
                    reject("NOT_FOUND", "Article not found", nil)
                    return
                }

                let item: [String: Any] = [
                    "id": article.id,
                    "title": article.title,
                    "summary": article.summary,
                    "body": article.body,
                    "image": article.imageUrl,
                    "source": article.source,
                    "time": article.publishedAt,
                    "category": article.category
                ]
                resolve(item)

            case .failure(let error):
                reject("NETWORK_ERROR", error.localizedDescription, error)
            }
        }
    }
}
