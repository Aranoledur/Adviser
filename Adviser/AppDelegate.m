//
//  AppDelegate.m
//  Adviser
//
//  Created by user on 16.09.15.
//  Copyright (c) 2015 user. All rights reserved.
//

#import "AppDelegate.h"

#define FileLocalNameRU @"somefile_ru"
#define FileLocalNameEN @"somefile_en"

@interface AppDelegate ()
@property (nonatomic, strong) NSString* localFileName;
@property (nonatomic, strong) NSString* fileURL;
@end

@implementation AppDelegate

- (void)shuffleArray:(NSMutableArray *)array
{
    NSUInteger count = [array count];
    if (count < 1) return;
    for (NSUInteger i = 0; i < count - 1; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [array exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

-(NSMutableArray *) colors {
    if (!_colors) {
        _colors = [NSMutableArray new];
    }
    return _colors;
}

-(BOOL)loadJSON:(NSData *)data {
    NSError *error = nil;
    NSDictionary* ads = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"bad json");
        return false;
    }
    
    self.advices = [ads objectForKey:@"advices"];
    [self shuffleArray:self.advices];
    NSArray* colors = [ads objectForKey:@"colors"];
    
    [self.colors removeAllObjects];
    for (NSDictionary* color in colors) {
        
        NSNumber* r = [color objectForKey:@"r"];
        NSNumber* g = [color objectForKey:@"g"];
        NSNumber* b = [color objectForKey:@"b"];
        UIColor* color = [[UIColor alloc] initWithRed:[r intValue]/255.f green:[g intValue]/255.f blue:[b intValue]/255.f alpha:1.f];
        [self.colors addObject:color];
    }
    return true;
}

-(void)getLocalDataForView {
    NSString* filePath = [[NSBundle mainBundle] pathForResource:self.localFileName ofType:@"json"];
    
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    [self loadJSON:data];
}

-(void) getDataForView {
    
    NSURLSession* session = [NSURLSession sharedSession];
    NSURL* url = [NSURL URLWithString:self.fileURL];
    NSURLSessionTask* task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!data) {
            NSLog(@"bad data");
            return;
        }
        BOOL good = [self loadJSON:data];
        
        if (good) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationName" object:nil];
            });
        }
    }];
    [task resume];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSString* locale = [[[NSLocale preferredLanguages] objectAtIndex:0] substringToIndex:2];
    if ([locale rangeOfString:@"ru"].location == NSNotFound) {
        self.localFileName = FileLocalNameEN;
        self.fileURL = @"https://raw.githubusercontent.com/Aranoledur/Adviser/master/Adviser/somefile_en.json";
    } else {
        self.localFileName = FileLocalNameRU;
        self.fileURL = @"https://raw.githubusercontent.com/Aranoledur/Adviser/master/Adviser/somefile_ru.json";
    }
    [self getDataForView];
    [self getLocalDataForView];
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
