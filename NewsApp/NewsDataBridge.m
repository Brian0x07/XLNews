//
//  NewsDataBridge.m
//  NewsApp
//
//  RN 原生模块 — 暴露 GraphQL 数据给 React Native
//  实际逻辑在 NewsDataBridge.swift 中实现
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(NewsDataBridge, NSObject)

RCT_EXTERN_METHOD(fetchNewsFeed:(NSString *)category
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(fetchArticle:(NSString *)articleId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
