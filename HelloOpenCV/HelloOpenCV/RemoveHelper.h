//
//  RemoveHelper.h
//  HelloOpenCV
//
//  Created by Yanxi Pan on 4/9/14.
//  Copyright (c) 2014 Taikun Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RemoveHelper : NSObject {
    NSMutableArray *imgs;
    cv::Mat baseImg;
    std::vector<cv::Rect> basePeds;
    std::vector<bool> removed;
    std::vector<cv::Mat> resImgs;
    std::vector<std::vector<Byte>> resPedsStack;
    std::vector<cv::Mat> homos;
    cv::Mat resultImg;
}

/* RemoveHelper *r = [[RemoveHelper alloc] initWithImages:images];
 * Recognize all pedestrains in all pictures, choose the base image
 */
- (id)initWithImages:(NSMutableArray *) images;

- (void) doRecognition;

/*Return the base image with rectangles*/
-(UIImage *) getBaseImg;

/*Return the rectangle array of base image*/
-(NSMutableArray *) getBasePedestians;

/*Remove the pedestrian given a index array*/
- (UIImage *) removePedestrian:(NSMutableArray *) indexArray;

/*Get result image*/
- (UIImage *) getResultImage;

/*Reverse all change*/
- (UIImage *) resetResultImage;

- (void) detectPedestrian;

- (UIImage *)remove:(int) index;

@end
