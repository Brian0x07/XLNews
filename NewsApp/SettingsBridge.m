//
//  SettingsBridge.m
//  NewsApp
//

#import <React/RCTBridgeModule.h>

@interface SettingsBridge : NSObject <RCTBridgeModule>
@end

@implementation SettingsBridge

RCT_EXPORT_MODULE();

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_METHOD(applyTheme:(NSString *)theme) {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isDark = [theme isEqualToString:@"dark"];

        UIWindow *window = nil;
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                window = ((UIWindowScene *)scene).windows.firstObject;
                break;
            }
        }
        if (!window) return;

        window.overrideUserInterfaceStyle = isDark ? UIUserInterfaceStyleDark : UIUserInterfaceStyleLight;

        UINavigationController *nav = (UINavigationController *)window.rootViewController;
        if (![nav isKindOfClass:[UINavigationController class]]) return;

        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];

        if (isDark) {
            appearance.backgroundColor = [UIColor colorWithRed:0.11 green:0.11 blue:0.13 alpha:1.0];
            appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
            nav.navigationBar.tintColor = [UIColor colorWithRed:0.40 green:0.56 blue:1.0 alpha:1.0];
        } else {
            appearance.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.98 alpha:1.0];
            appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
            nav.navigationBar.tintColor = [UIColor colorWithRed:0.29 green:0.43 blue:0.88 alpha:1.0];
        }

        nav.navigationBar.standardAppearance = appearance;
        nav.navigationBar.scrollEdgeAppearance = appearance;
    });
}

@end
