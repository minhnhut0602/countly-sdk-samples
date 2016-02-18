// AppDelegate.m
//
// This code is provided under the MIT License.
//
// Please visit www.count.ly for more information.

#import "AppDelegate.h"
#import "Countly.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    CountlyConfig* config = CountlyConfig.new;
    config.appKey = @"YOUR_APP_KEY";
    config.host = @"https://YOUR_COUNTLY_SERVER";
//  config.deviceID = @"customDeviceID"                               //Optional custom or system generated device ID
//  config.features = @[CLYMessaging, CLYCrashReporting, CLYAPM, CLYViewTracking];     //Optional features
//  config.launchOptions = launchOptions;                             //Required for CLYMessaging feature
    [Countly.sharedInstance startWithConfig:config];

    return YES;
}

@end