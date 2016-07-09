//
//  ImageViewCollectionViewCell.m
//  Image Gallery
//
//  Created by Irfan Godinjak on 09/05/16.
//  Copyright © 2016 Godinjak. All rights reserved.
//

#import "ImageViewCollectionViewCell.h"

@implementation ImageViewCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void) layoutSubviews{
    [super layoutSubviews];
    _imageView.contentMode = UIViewContentModeScaleToFill;
}

@end
