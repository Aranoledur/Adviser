//
//  AppDelegate.m
//  Adviser
//
//  Created by user on 16.09.15.
//  Copyright (c) 2015 user. All rights reserved.
//

#import "AppDelegate.h"
#import <Firebase/Firebase.h>

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

-(void)scheduleLocalNotifications {
    NSMutableArray* indices = [NSMutableArray new];
    for (int k = 0; k < self.advices.count; ++k) {
        [indices addObject:[[NSNumber alloc] initWithInt:k]];
    }
    [self shuffleArray:indices];
    for (int i = 1; i <= 3; ++i) {
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* dateComp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[NSDate new]];
        dateComp.day += i;
        for (int j = 0; j < 3; ++j) {
            dateComp.hour = 9 + j*5;
            if (i+j < indices.count) {
                UILocalNotification* notification = [[UILocalNotification alloc] init];
                notification.fireDate = [calendar dateFromComponents:dateComp];
                int index = ((NSNumber *)indices[i+j]).intValue;
                notification.alertBody = self.advices[index];
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        }
    }
}

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

-(void)setupFirebase {
    
    [Firebase defaultConfig].persistenceEnabled = YES;

    __weak AppDelegate* weakSelf = self;

    Firebase *myRootRef = [[Firebase alloc] initWithUrl:@"https://omadviser.firebaseio.com"];
    [myRootRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSDictionary* root = snapshot.value;
        
        NSString* advicesKey = [self.localFileName compare:FileLocalNameEN] == NSOrderedSame ? @"advices_en" : @"advices_ru";
        if ([root objectForKey:advicesKey]) {
            [weakSelf.advices removeAllObjects];
            weakSelf.advices = [root objectForKey:advicesKey];

            NSIndexSet* indexSet = [weakSelf.advices indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return ![obj isKindOfClass:[NSString class]];
            }];
            [weakSelf.advices removeObjectsAtIndexes:indexSet];
            [weakSelf shuffleArray:self.advices];
        }
        
        if ([root objectForKey:@"colors"]) {
            [weakSelf.colors removeAllObjects];
            NSArray* colors = [root objectForKey:@"colors"];
            for (NSString* colorStr in colors) {
                if (![colorStr isKindOfClass:[NSString class]]) {
                    continue;
                }
                unsigned result = 0;
                NSScanner *scanner = [NSScanner scannerWithString:colorStr];
                
                [scanner setScanLocation:1]; // bypass '#' character
                [scanner scanHexInt:&result];
                UIColor *color = UIColorFromRGB(result);
                [weakSelf.colors addObject: color];
            }
            [weakSelf shuffleArray:weakSelf.colors];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationName" object:nil];
    }];
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
    [self getLocalDataForView];
    [self setupFirebase];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self scheduleLocalNotifications];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self shuffleArray:self.advices];
    [self shuffleArray:self.colors];
    [application cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
