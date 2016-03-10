//
//  ViewController.m
//  Adviser
//
//  Created by user on 16.09.15.
//  Copyright (c) 2015 user. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()
@property (nonatomic, strong, readwrite) NSArray* texts;
@property (nonatomic, strong, readwrite) NSArray* backColors;

@property (nonatomic, assign) NSInteger textIndex;
@property (nonatomic, assign) NSInteger colorsIndex;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (strong, nonatomic) IBOutlet UIView *mainView;

@end

@implementation ViewController

-(void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveData:) name:@"NotificationName" object:nil];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate* app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.texts = [[NSArray alloc] initWithArray:app.advices copyItems:YES];
    self.backColors = [[NSArray alloc] initWithArray:app.colors copyItems:YES];
    
    self.mainLabel.text = [self.texts objectAtIndex:self.textIndex];
    self.mainView.backgroundColor = [self.backColors objectAtIndex:self.colorsIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)nextButtonTouched:(id)sender {
    self.textIndex++;// = arc4random_uniform((u_int32_t)self.texts.count);
    self.colorsIndex++;// = arc4random_uniform((u_int32_t)self.backColors.count);
    if(self.textIndex >= self.texts.count)
        self.textIndex = 0;
    if(self.colorsIndex >= self.backColors.count)
        self.colorsIndex = 0;
    
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    animation.type = kCATransitionFade;
    animation.duration = 0.75;
    [self.mainLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
    self.mainLabel.text = [self.texts objectAtIndex:self.textIndex];
    
    CATransition *animationBack = [CATransition animation];
    animationBack.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    animationBack.type = kCATransitionFade;
    animationBack.duration = 0.75;
    [self.mainView.layer addAnimation:animationBack forKey:@"kCATransitionFade"];
    self.mainView.backgroundColor = [self.backColors objectAtIndex:self.colorsIndex];
}

- (IBAction)respondToTapGesture:(id)sender {
    [self nextButtonTouched:nil];
}

-(void)didReceiveData:(NSNotification *)notif {
    AppDelegate* app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.texts = [[NSArray alloc] initWithArray:app.advices copyItems:YES];
    self.backColors = [[NSArray alloc] initWithArray:app.colors copyItems:YES];
}

@end
