//
//  ImageEffectsModel.m
//  Image Gallery
//
//  Created by Irfan Godinjak on 09/05/16.
//  Copyright © 2016 Godinjak. All rights reserved.
//

#import "ImageEffectsModel.h"
@import UIKit;
@implementation ImageEffectsModel
@synthesize image, negativeImage, grayImage;

float r[255], g[255], b[255];

float rr[255], gg[255], bb[255];

- (id) init{
    return [self initWithImage:image];
}

- (id)initWithImage:( UIImage* _Nonnull  )img {
    self = [super init];
    if (self) {
        image = img;
    }
    return self;
}

- (void) findMeHistogram{
    self.redArray = [NSMutableArray arrayWithCapacity:255];
    self.greenArray = [NSMutableArray arrayWithCapacity:255];
    self.blueArray = [NSMutableArray arrayWithCapacity:255];

    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    for (int yy=0;yy<height; yy++) {
        for (int xx=0; xx<width; xx++) {
            long byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel;
            for (int ii = 0 ; ii < 1 ; ++ii){
                CGFloat red   = (rawData[byteIndex]     * 1.0) ;
                CGFloat green = (rawData[byteIndex + 1] * 1.0) ;
                CGFloat blue  = (rawData[byteIndex + 2] * 1.0) ;
                byteIndex += 4;
                
                int redValue = (int)red;
                int greenValue = (int)green;
                int blueValue = (int)blue;
                
                r[redValue]++;
                g[greenValue]++;
                b[blueValue]++;
            }
        }
    }
    {
        float max=0;
        int maxR=0;
        int maxG=0;
        int maxB=0;
        
        for (int i=0; i<255; i++){
            maxR += r[i];
            maxG += g[i];
            maxB += b[i];
        }
        
        maxR = maxR/255;
        maxG = maxG/255;
        maxB = maxB/255;
        max = (maxR+maxG+maxB)/3;
        
        // DEVIDED BY 8 TO GET GRAPH OF THE SAME SIZE AS ITS IN PREVIEW
        //        max = max*8;
        CGFloat scale = [[UIScreen mainScreen] scale];
        
        for (int i=0; i<255; i++){
            [_redArray addObject:[NSNumber numberWithFloat:r[i]*scale/max]];
            [_greenArray addObject:[NSNumber numberWithFloat:g[i]*scale/max]];
            [_blueArray addObject:[NSNumber numberWithFloat:b[i]*scale/max]];
        }
    }
    free(rawData);
}

- (UIImage *)negativeImage{
    if (!negativeImage) {
        
        CGFloat scale = [[UIScreen mainScreen] scale];
        
        CGSize size = [image size];
        int width = size.width *scale;
        int height = size.height *scale;
        
        // the pixels will be painted to this array
        uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
        
        // clear the pixels so any transparency is preserved
        memset(pixels, 0, width * height * sizeof(uint32_t));
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // create a context with RGBA pixels
        CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                     kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
        
        // paint the bitmap to our context which will fill in the pixels array
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), [image CGImage]);
        
        for(int y = 0; y < height; y++) {
            for(int x = 0; x < width; x++) {
                uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
                                
                // set the pixels to gray
                rgbaPixel[3] = 255 - rgbaPixel[3];
                rgbaPixel[2] = 255 - rgbaPixel[2];
                rgbaPixel[1] = 255 - rgbaPixel[1];
            }
        }
        
        // create a new CGImageRef from our context with the modified pixels
        CGImageRef img = CGBitmapContextCreateImage(context);
        
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        free(pixels);
        
        // make a new UIImage to return
        negativeImage = [UIImage imageWithCGImage:img scale:scale orientation:UIImageOrientationUp];
        
        CGImageRelease(img);
    }
    return negativeImage;
}

- (UIImage *)grayImage{
    if (!grayImage) {
        
        CGFloat scale = [[UIScreen mainScreen] scale];
        
        CGSize size = [image size];
        int width = size.width *scale;
        int height = size.height *scale;
        
        // the pixels will be painted to this array
        uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
        
        // clear the pixels so any transparency is preserved
        memset(pixels, 0, width * height * sizeof(uint32_t));
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // create a context with RGBA pixels
        CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                     kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
        
        // paint the bitmap to our context which will fill in the pixels array
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), [image CGImage]);
        
        for(int y = 0; y < height; y++) {
            for(int x = 0; x < width; x++) {
                uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
                
                uint32_t gray = 0.21 * rgbaPixel[3] + 0.72 * rgbaPixel[2] + 0.07 * rgbaPixel[1];
                
                // set the pixels to gray
                rgbaPixel[3] = gray;
                rgbaPixel[2] = gray;
                rgbaPixel[1] = gray;
            }
        }
        
        // create a new CGImageRef from our context with the modified pixels
        CGImageRef img = CGBitmapContextCreateImage(context);
        
        // we're done with the context, color space, and pixels
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        free(pixels);
        
        // make a new UIImage to return
        grayImage = [UIImage imageWithCGImage:img scale:scale orientation:UIImageOrientationUp];
        
        // we're done with image now too
        CGImageRelease(img);
    }
    return grayImage;
}
@end
