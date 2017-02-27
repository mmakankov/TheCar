//
//  ViewController.h
//  TheCar
//
//  Created by Admin on 25.02.17.
//  Copyright © 2017 mmakankov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CarView;

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *carView;
@property (weak, nonatomic) IBOutlet UISwitch *ignoreTouchesSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *animateRadiusSwitch;

@end

