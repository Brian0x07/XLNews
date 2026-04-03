//
//  RNViewFactory.m
//  RNViewFactory
//

#import "RNViewFactory.h"
#import <React/RCTBundleURLProvider.h>
#import <React_RCTAppDelegate/RCTRootViewFactory.h>
#import <React_RCTAppDelegate/RCTDefaultReactNativeFactoryDelegate.h>
#import <React_RCTAppDelegate/RCTReactNativeFactory.h>

@interface RNFactoryDelegate : RCTDefaultReactNativeFactoryDelegate
@end

@implementation RNFactoryDelegate

- (NSURL *)bundleURL {
    return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
}

- (BOOL)bridgelessEnabled {
    return NO;
}

@end

@implementation RNViewFactory

+ (RCTReactNativeFactory *)sharedReactNativeFactory {
    static RCTReactNativeFactory *factory = nil;
    static RNFactoryDelegate *delegate = nil; // strong reference to prevent dealloc
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        delegate = [RNFactoryDelegate new];
        factory = [[RCTReactNativeFactory alloc] initWithDelegate:delegate];
    });
    return factory;
}

+ (UIView *)createRootViewWithModuleName:(NSString *)moduleName {
    return [self createRootViewWithModuleName:moduleName initialProperties:nil];
}

+ (UIView *)createRootViewWithModuleName:(NSString *)moduleName
                       initialProperties:(NSDictionary *)initialProperties {
    RCTRootViewFactory *rootViewFactory = [self sharedReactNativeFactory].rootViewFactory;
    UIView *rootView = [rootViewFactory viewWithModuleName:moduleName
                                        initialProperties:initialProperties];
    rootView.backgroundColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.11 alpha:1.0];
    return rootView;
}

@end
