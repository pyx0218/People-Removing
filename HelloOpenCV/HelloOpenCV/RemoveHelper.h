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

- (id)initWithImages:(NSMutableArray *) images;
- (UIImage *) doRecognition;
- (UIImage *) removePedestrian:(double) x :(double) y;
- (UIImage *) getResultImage;
- (UIImage *) resetResultImage;

@end
