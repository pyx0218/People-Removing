//
//  RemoveHelper.m
//  HelloOpenCV
//
//  Created by Yanxi Pan on 4/9/14.
//  Copyright (c) 2014 Taikun Liu. All rights reserved.
//

#import "RemoveHelper.h"
#import "opencv2/highgui/ios.h"

@implementation RemoveHelper

- (id)initWithImages:(NSMutableArray *) images {
    self = [super init];
    if (self) {
        imgs = images;
    }
    return self;
}

- (UIImage *) doRecognition {
    for(int i=0; i<[imgs count]; i++) {
        UIImage *img = [imgs objectAtIndex:i];
        //Recognize pedestrians
        cv::Mat cvImage;
        UIImageToMat(img, cvImage);
        std::vector<cv::Rect> found = [self pedestrianRec:cvImage];
        
        //Set base and resource images and pedestrian arrays
        if(i == 0) {
            baseImg = cvImage;
            basePeds = found;
        }
        else {
            resImgs.push_back(cvImage);
            resPeds.push_back(found);
        }
    }
    //Display pedestrian rectangles on base image
    cv::Mat dispImg = [self displayPeds:baseImg :basePeds];
    return MatToUIImage(dispImg);
}

- (void) setBaseImg {
    
}

- (std::vector<cv::Rect>)pedestrianRec:(cv::Mat) cvImage {
    
    cvtColor(cvImage , cvImage , CV_RGBA2RGB);
    std::vector<cv::Rect> found;
    
    if (!cvImage.empty())
    {
        NSLog(@"image size is %d * %d\n",cvImage.cols,cvImage.rows);
        cv::HOGDescriptor hog;
        hog.setSVMDetector(cv::HOGDescriptor::getDefaultPeopleDetector());
        hog.detectMultiScale(cvImage, found, 0, cv::Size(8,8), cv::Size(32,32), 1.05, 2);
        for(int i=0;i<found.size();i++){
            cv::Rect r=found[i];
            if(r.tl().x < 0) {
                cv::Rect newr(0, r.tl().y, r.br().x, r.height);
                r = newr;
                found[i] = r;
            }
            if(r.tl().y < 0) {
                cv::Rect newr(r.tl().x, 0, r.width, r.br().y);
                r = newr;
                found[i] = r;
            }
            if(r.br().x > cvImage.cols) {
                cv::Rect newr(r.tl().x, r.tl().y, cvImage.cols-r.tl().x, r.height);
                r = newr;
                found[i] = r;
            }
            if(r.br().y > cvImage.rows) {
                cv::Rect newr(r.tl().x, r.tl().y, r.width, cvImage.rows - r.tl().y);
                r = newr;
                found[i] = r;
            }
            NSLog(@"rect %d: tl (%d, %d) br (%d, %d)\n",i, r.tl().x,r.tl().y, r.br().x, r.br().y);
        }
    }
    cvImage.release();
    
    return found;
}


- (cv::Mat) displayPeds:(cv::Mat) img :(std::vector<cv::Rect>) peds {
    cv::Mat dispImg = img.clone();
    for(int i=0;i<peds.size();i++){
        cv::Rect r = peds[i];
        rectangle(dispImg, r.tl(), r.br(), cv::Scalar(0,255,0),4);
    }
    return dispImg;
}

- (int) getIndex:(double) x :(double) y {
    cv::Point p(x, y);
    for(int i=0; i<basePeds.size(); i++) {
        if(p.inside(basePeds[i])) {
            return i;
        }
    }
    return -1;
}

- (UIImage *)removePedestrian:(double) x :(double) y {
    //several steps
    //1. compute homography
    //2. find rectangles that are not intersects or overlap the least
    //3. copy images.
    int index = [self getIndex:x :y];
    if(index < 0) {
        NSLog(@"Not a pedestrian!");
        return MatToUIImage(baseImg);
    }
    
    cv::Rect rectRemove = basePeds[index];
    resultImg = baseImg.clone();
    //small rectangle
    int dx = 10;
    int dy = 10;
    
    int cntx = rectRemove.width/dx;
    int cnty = rectRemove.height/dy;
    int modx = rectRemove.width%dx;
    int mody = rectRemove.height%dy;
    
    int w = 0;
    int h = 0;
    
    for (int k=0; k<=cnty; k++) {
        if(k == cnty) {
            if(mody == 0) break;
            else h = mody;
        }
        else {
            h = dy;
        }
        for (int l=0; l<=cntx; l++) {
            if(l == cntx) {
                if(modx == 0) break;
                else w = modx;
            }
            else {
                w = dx;
            }
            cv::Rect smallr(rectRemove.tl().x+l*dx, rectRemove.tl().y+k*dy, w, h);
            double minArea = w*h;
            int minId = -1;
            for (int i=0;i<resImgs.size();i++)
            {
                cv::Mat cvImg = resImgs[i];
                std::vector<cv::Rect> peds = resPeds[i];
                bool interb=false;
                for(int j=0; j<peds.size(); j++) {
                    cv::Rect rectReplace = peds[j];
                    cv::Rect inter = smallr & rectReplace;
                    if(inter.area()!=0)
                    {
                        interb=true;
                        if(inter.area() < minArea) {
                            minArea = inter.area();
                            minId = i;
                        }
                    }
                }
                if(!interb)
                {
                    minId = i;
                    break;
                }
            }
            if(minId >= 0) {
                resImgs[minId](smallr).copyTo(resultImg(smallr));
            }
        }
    }
    
    return MatToUIImage(resultImg);
}


@end
