//
//  ImageEffectsModel.h
//  Image Gallery
//
//  Created by Irfan Godinjak on 09/05/16.
//  Copyright © 2016 Godinjak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageEffectsModel : NSObject

@property (nonatomic, nonnull) NSMutableArray *redArray;
@property (nonatomic, nonnull) NSMutableArray *greenArray;
@property (nonatomic, nonnull) NSMutableArray *blueArray;

@property (nonatomic, nonnull) UIImage *image;
@property (nonatomic, nonnull) UIImage *negativeImage;
@property (nonatomic, nonnull) UIImage *grayImage;


- (id _Nonnull)initWithImage: ( UIImage* _Nonnull )img;
- (void) findMeHistogram;

@end
