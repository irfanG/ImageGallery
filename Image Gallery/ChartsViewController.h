//
//  ChartsViewController.h
//  Image Gallery
//
//  Created by Irfan Godinjak on 09/05/16.
//  Copyright © 2016 Godinjak. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Image Gallery-Bridging-Header.h"

@interface ChartsViewController : UIViewController<ChartViewDelegate>
@property (nonatomic, nonnull) NSMutableArray *redArray;
@property (nonatomic, nonnull) NSMutableArray *greenArray;
@property (nonatomic, nonnull) NSMutableArray *blueArray;
@end
