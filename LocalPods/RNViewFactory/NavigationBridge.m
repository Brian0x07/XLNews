//
//  NavigationBridge.m
//  RNViewFactory
//

#import "NavigationBridge.h"
#import "RNViewFactory.h"

@implementation NavigationBridge

RCT_EXPORT_MODULE();

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_METHOD(pushNewsDetail:(NSDictionary *)newsData) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *topVC = [self topViewController];
        UINavigationController *nav = topVC.navigationController;
        if (!nav) return;

        UIView *rnView = [RNViewFactory createRootViewWithModuleName:@"NewsDetail"
                                                   initialProperties:newsData];
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.11 alpha:1.0];
        rnView.frame = vc.view.bounds;
        rnView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [vc.view addSubview:rnView];
        vc.title = @"Detail";
        [nav pushViewController:vc animated:YES];
    });
}

- (UIViewController *)topViewController {
    UIWindow *window = nil;
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            window = windowScene.windows.firstObject;
            break;
        }
    }
    UIViewController *vc = window.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return ((UINavigationController *)vc).topViewController;
    }
    return vc;
}

@end
