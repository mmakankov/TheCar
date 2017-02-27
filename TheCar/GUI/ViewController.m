//
//  ViewController.m
//  TheCar
//
//  Created by Admin on 25.02.17.
//  Copyright © 2017 mmakankov. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <CAAnimationDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) UITapGestureRecognizer *tapGesture;
@property (nonatomic) BOOL isAnimating;

@end

@implementation ViewController

const NSTimeInterval timeInterval = 2.0;
const CGFloat maxRadius = 60.0;
const CGFloat minRadius = 0.1;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    self.tapGesture = tap;
}

- (void)animateWithDestination:(CGPoint)destination {
    self.isAnimating = YES;
    CALayer *presentationLayer = [self.carView.layer presentationLayer];
    CGPoint currentPosition = presentationLayer.position;
    CGFloat needAngle = atan2f(destination.y - currentPosition.y, destination.x - currentPosition.x);
    CGFloat currentAngle = [(NSNumber *)[presentationLayer valueForKeyPath:@"transform.rotation.z"] floatValue];
    
    CGFloat radius = minRadius;
    if (self.animateRadiusSwitch.isOn) {
        CGFloat halfDistance = hypotf(destination.x - currentPosition.x, destination.y - currentPosition.y) / 2;
        radius = MIN(halfDistance, maxRadius);
    }
    
    //Calculate direction of rotation
    CGFloat provisionalAngle = needAngle - currentAngle;
    CGFloat turnAngle = provisionalAngle;
    
    if (fabs(provisionalAngle) <= M_PI) {
        turnAngle = provisionalAngle;
    } else if (provisionalAngle > M_PI) {
        turnAngle = provisionalAngle - 2 * M_PI;
    } else if (provisionalAngle < -M_PI) {
        turnAngle = provisionalAngle + 2 * M_PI;
    }
    BOOL isClockwise = turnAngle > 0;
    //=====
    
    CGFloat circleAngle = currentAngle + (turnAngle > 0 ? M_PI_2 : - M_PI_2);
    CGPoint circleCenter = CGPointMake(currentPosition.x + radius * cosf(circleAngle), currentPosition.y + radius * sinf(circleAngle));
    CGFloat endAngle = atan2f(destination.y - circleCenter.y, destination.x - circleCenter.x);
    CGFloat dist = hypotf(destination.x - circleCenter.x, destination.y - circleCenter.y);
    CGFloat angleToMinus = acosf(radius / dist);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:circleCenter
                                                        radius:radius
                                                    startAngle:currentAngle + (isClockwise ? - M_PI_2 : M_PI_2)
                                                      endAngle:endAngle + (isClockwise ? - angleToMinus : angleToMinus)
                                                     clockwise:isClockwise];
    [path addLineToPoint:destination];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.duration = timeInterval;
    animation.rotationMode = kCAAnimationRotateAuto;
    animation.path = path.CGPath;
    animation.calculationMode = self.animateRadiusSwitch.isOn ? kCAAnimationCubicPaced : kCAAnimationLinear;
    animation.delegate = self;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [self.carView.layer addAnimation:animation forKey:@"moveTheCar"];
}

#pragma mark - Actions
- (IBAction)ignoreSwitchValueChanged:(UISwitch *)sender {
    if (self.isAnimating) {
        self.tapGesture.enabled = !sender.isOn;
    }
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    if (self.ignoreTouchesSwitch.isOn) {
        self.tapGesture.enabled = NO;
    }
    [self animateWithDestination:[recognizer locationInView:recognizer.view]];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.tapGesture.enabled = YES;
    if (flag) {
        self.isAnimating = NO;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view == gestureRecognizer.view;
}

@end

