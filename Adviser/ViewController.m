//
//  ViewController.m
//  Adviser
//
//  Created by user on 16.09.15.
//  Copyright (c) 2015 user. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong, readwrite) NSArray* texts;
@property (nonatomic, strong, readwrite) NSArray* backColors;

@property (nonatomic, assign) NSInteger textIndex;
@property (nonatomic, assign) NSInteger colorsIndex;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.texts = [NSArray arrayWithObjects:@"Be be be", @"Be be be Be be be Be be be Be be be Be be be Be be be Be be be ", @"Be be be Be be be Be be be ", nil];
    self.backColors = [NSArray arrayWithObjects:[UIColor colorWithRed:177.f/255 green:246.f/255 blue:165.f/255 alpha:1.f], [UIColor colorWithRed:246.f/255 green:236.f/255 blue:164.f/255 alpha:1.f], nil];
    
    self.mainLabel.text = [self.texts objectAtIndex:self.textIndex];
    self.mainView.backgroundColor = [self.backColors objectAtIndex:self.colorsIndex];
    
    self.mainLabel.center = CGPointMake([self.mainView bounds].size.width/2, [self.mainView bounds].size.height*1/4);
    self.nextButton.center = CGPointMake([self.mainView bounds].size.width/2, [self.mainView bounds].size.height*3/4);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)nextButtonTouched:(id)sender {
    ++self.textIndex;
    ++self.colorsIndex;
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

@end
