/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <AWSS3.h>


@implementation AppDelegate

+(AppDelegate *)sharedAppDelegate
{
  static AppDelegate *appDelegate = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  });
  return appDelegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSURL *jsCodeLocation;

  jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];

  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"DemoImgUpload"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  NSString *accessKey = @"AWSKey";
  NSString *secretKey = @"AWSAccessKey";
  
  AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:accessKey secretKey:secretKey];
  AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
  
  configuration.timeoutIntervalForRequest = 3000;
  configuration.timeoutIntervalForResource = 180;
  configuration.maxRetryCount = 3;
  
  [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
  
  self.queue = [[NSOperationQueue alloc] init];
  self.queue.maxConcurrentOperationCount = 1;
  [self.queue waitUntilAllOperationsAreFinished];
  
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

@end
