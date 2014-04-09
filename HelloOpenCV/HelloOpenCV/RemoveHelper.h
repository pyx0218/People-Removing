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
    std::vector<std::vector<cv::Rect>> resPeds;
    cv::Mat resultImg;
}

/*RemoveHelper *r = [[RemoveHelper alloc] initWithImages:images];*/
- (id)initWithImages:(NSMutableArray *) images;

/*Recognize all pedestrains in all pictures, choose the base image, display rectangles*/
- (UIImage *) doRecognition;

/*Remove the pedestrian given a point*/
- (UIImage *) removePedestrian:(double) x :(double) y;

/*Get result image*/
- (UIImage *) getResultImage;

/*Reverse all change*/
- (UIImage *) resetResultImage;

@end
