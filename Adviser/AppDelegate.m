//
//  AppDelegate.m
//  Adviser
//
//  Created by user on 16.09.15.
//  Copyright (c) 2015 user. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

-(NSMutableArray *) colors {
    if (!_colors) {
        _colors = [NSMutableArray new];
    }
    return _colors;
}

-(void) getDataForView {
    
    NSURLSession* session = [NSURLSession sharedSession];
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"somefile" ofType:@"json"];
    NSURL* url = [NSURL fileURLWithPath:filePath];
    NSURLSessionTask* task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!data) {
            NSLog(@"bad data");
            return;
        }
        
        NSDictionary* ads = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        self.advices = [ads objectForKey:@"advices"];
        NSArray* colors = [ads objectForKey:@"colors"];
        
        [self.colors removeAllObjects];
        for (NSDictionary* color in colors) {
            
            NSLog(@"dic %@", color);
            NSNumber* r = [color objectForKey:@"r"];
            NSNumber* g = [color objectForKey:@"g"];
            NSNumber* b = [color objectForKey:@"b"];
            UIColor* color = [[UIColor alloc] initWithRed:[r intValue]/255.f green:[g intValue]/255.f blue:[b intValue]/255.f alpha:1.f];
            [self.colors addObject:color];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationName" object:nil];
        });
    }];
    [task resume];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self getDataForView];
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
    [self getDataForView];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
