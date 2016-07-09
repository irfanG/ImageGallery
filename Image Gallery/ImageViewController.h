//
//  ImageViewController.h
//  Image Gallery
//
//  Created by Irfan Godinjak on 09/05/16.
//  Copyright © 2016 Godinjak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageEffectsModel.h"
#import "Image Gallery-Bridging-Header.h"


@interface ImageViewController : UIViewController<ChartViewDelegate>

@property (nonatomic, retain) ImageEffectsModel *imgeEffectModel;

@end
