//
//  RNViewFactory.h
//  RNViewFactory
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNViewFactory : NSObject
+ (UIView *)createRootViewWithModuleName:(NSString *)moduleName;
+ (UIView *)createRootViewWithModuleName:(NSString *)moduleName
                       initialProperties:(NSDictionary *_Nullable)initialProperties;
@end

NS_ASSUME_NONNULL_END
