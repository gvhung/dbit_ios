//
//  AppDelegate.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "AppDelegate.h"
#import "OPLeftDrawerViewController.h"
#import "TimeTableViewController.h"
#import "LectureViewController.h"
#import "ShowTimeTableViewController.h"
#import "UIColor+OPTheme.h"
#import "UIFont+OPTheme.h"
#import "DataManager.h"

#import "MZSnackBar.h"

// Models
#import "ServerLectureObject.h"
#import "TimeTableObject.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate () <OPLeftDrawerViewControllerDelegate>

@property (strong, nonatomic) MZSnackBar *snackBar;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [RLMRealm setSchemaVersion:1
                forRealmAtPath:[RLMRealm defaultRealmPath]
            withMigrationBlock:^(RLMMigration *migration, uint64_t oldSchemaVersion) {
                if (oldSchemaVersion < 1) {
                    [migration enumerateObjects:ServerLectureObject.className
                                          block:^(RLMObject *oldObject, RLMObject *newObject) {
                                              newObject[@"lectureKey"] = [NSString stringWithFormat:@"%@", oldObject[@"lectureCode"]];
                                          }];
                    [migration enumerateObjects:TimeTableObject.className
                                          block:^(RLMObject *oldObject, RLMObject *newObject) {
                                              if ([oldObject[@"sat"] boolValue] || [oldObject[@"sun"] boolValue]) {
                                                  newObject[@"workAtWeekend"] = @(YES);
                                              } else {
                                                  newObject[@"workAtWeekend"] = @(NO);
                                              }
                                          }];
                }
            }];
    
    [Fabric with:@[CrashlyticsKit]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    OPLeftDrawerViewController *leftDrawerViewController = [[OPLeftDrawerViewController alloc] init];
    leftDrawerViewController.delegate = self;
    
    if ([DataManager sharedInstance].activedTimeTable) {
        LectureViewController *lectureViewController = [[LectureViewController alloc] init];
        _centerNavigationController = [[UINavigationController alloc] initWithRootViewController:lectureViewController];
    } else {
        TimeTableViewController *timeTableViewController = [[TimeTableViewController alloc] init];
        _centerNavigationController = [[UINavigationController alloc] initWithRootViewController:timeTableViewController];
    }
    _centerNavigationController.navigationBar.barTintColor = [UIColor op_primary];
    _centerNavigationController.navigationBar.translucent = NO;
    _centerNavigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor op_textPrimary],
                                                                      NSFontAttributeName : [UIFont op_title]};
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor op_textPrimary],
                                                                      NSFontAttributeName : [UIFont op_title]}
                                                forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTintColor:[UIColor op_textPrimary]];
    [[UITextField appearance] setTintColor:[UIColor op_textSecondaryDark]];
    
    if([UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)]) {
        [UINavigationBar appearance].tintColor = [UIColor op_textPrimary];
    }
    self.drawerController = [[MMDrawerController alloc] initWithCenterViewController:_centerNavigationController
                                                            leftDrawerViewController:leftDrawerViewController];

    [self.drawerController setRestorationIdentifier:@"MMDrawer"];
    [self.drawerController setMaximumLeftDrawerWidth:200.0];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeBezelPanningCenterView];
    self.drawerController.closeDrawerGestureModeMask ^= MMCloseDrawerGestureModeTapCenterView;
    self.drawerController.closeDrawerGestureModeMask ^= MMCloseDrawerGestureModePanningCenterView;
    self.drawerController.showsStatusBarBackgroundView = NO;
    [self.drawerController setShouldStretchDrawer:NO];
    
    [self.window setRootViewController:self.drawerController];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ( [[url host] isEqualToString:@"widget"]) {
        if ([[url path] isEqualToString:@"/show"]) {
            ShowTimeTableViewController *showTiemTableViewController = [[ShowTimeTableViewController alloc] init];
            [_centerNavigationController setViewControllers:@[showTiemTableViewController]];
            return YES;
        }
        if ([[url path] isEqualToString:@"/lecture"]) {
            LectureViewController *lectureViewController = [[LectureViewController alloc] init];
            [_centerNavigationController setViewControllers:@[lectureViewController]];
            return YES;
        }
        return YES;
    }
    return NO;
}

#pragma mark - Left Drawer View Controller Delegate

- (void)leftDrawerViewController:(OPLeftDrawerViewController *)viewController didFailedToTransitionWithMessage:(NSString *)message
{
    if (!_snackBar) {
        _snackBar = [[MZSnackBar alloc] initWithFrame:self.window.rootViewController.view.bounds];
    }
    _snackBar.message = message;
    [_snackBar animateToAppearInView:self.window.rootViewController.view];
}

@end
