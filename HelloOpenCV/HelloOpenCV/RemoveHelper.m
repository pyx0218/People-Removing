//
//  RemoveHelper.m
//  HelloOpenCV
//
//  Created by Yanxi Pan on 4/9/14.
//  Copyright (c) 2014 Taikun Liu. All rights reserved.
//

#import "RemoveHelper.h"
#import "opencv2/highgui/ios.h"
#include "opencv2/core/core.hpp"
#include "opencv2/features2d/features2d.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/calib3d/calib3d.hpp"
#include "opencv2/nonfree/nonfree.hpp"

@implementation RemoveHelper
using namespace cv;

- (id)initWithImages:(NSMutableArray *) images {
    self = [super init];
    if (self) {
        imgs = images;
        NSLog(@"Start recognition");
        [self doRecognition];
        NSLog(@"End recognition");
        NSLog(@"Start homography");
        [self getHomography];
        NSLog(@"End homography");
    }
    return self;
}

- (void) doRecognition {
    std::vector<std::vector<cv::Rect>> resPeds;
    for(int i=0; i<[imgs count]; i++) {
        //if(i > 0) break;
        UIImage *img = [imgs objectAtIndex:i];
        //Recognize pedestrians
        cv::Mat cvImage;
        UIImageToMat(img, cvImage);
        std::vector<cv::Rect> found = [self pedestrianRec:cvImage];
        
        //Set base and resource images and pedestrian arrays
        if(i == 0) {
            baseImg = cvImage;
            resultImg = baseImg.clone();
            basePeds = found;
            removed.assign(found.size(), false);
        }
        else {
            resImgs.push_back(cvImage);
            resPeds.push_back(found);
        }
    }
    if(resImgs.size() > 0) {
        int w = resImgs[0].cols;
        int h = resImgs[0].rows;
        resPedsStack.assign(h, std::vector<Byte>(w, 0));
    }
    for(int i=0; i<resImgs.size(); i++) {
        [self constructStack:resPeds[i] :i];
    }
}

- (void) getHomography {
    for(int i=0; i<resImgs.size(); i++) {
        homos.push_back([self getHomo:baseImg :resImgs[i]]);
    }
}

- (void) detectPedestrian {
    basePeds = [self judgeIfPerson:baseImg :basePeds];
    for(int i=0; i<resImgs.size(); i++) {
        NSLog(@"img #%d", i);
        //resPeds[i] = [self judgeIfPerson:resImgs[i] :resPeds[i]];
    }
}

-(UIImage *) getBaseImg {
    //Display pedestrian rectangles on base image
    cv::Mat dispImg = [self displayPeds:baseImg :basePeds];
    UIImage *img = MatToUIImage(dispImg);
    dispImg.release();
    return img;
}

-(NSMutableArray *) getBasePedestians {
    NSMutableArray *pedArray = [[NSMutableArray alloc] init];
    for(int i=0; i<basePeds.size(); i++) {
        cv::Rect r = basePeds[i];
        CGRect rectangle = CGRectMake(r.tl().x, r.tl().y, r.width, r.height);
        [pedArray addObject:[NSValue valueWithCGRect:rectangle]];
    }
    return pedArray;
}

- (void) setBaseImg {
    
}

- (void) constructStack:(std::vector<cv::Rect>) peds :(int) index {
    NSLog(@"%d\n", index);
    for(int i=0; i<peds.size(); i++) {
        cv::Rect r = peds[i];
        for(int j=r.tl().y; j<r.br().y; j++) {
            for(int k=r.tl().x; k<r.br().x; k++) {
                //NSLog(@"(%d,%d)\n", j, k);
                resPedsStack[j][k] |= 1<<index;
            }
        }
    }
}

- (std::vector<cv::Rect>)pedestrianRec:(cv::Mat) cvImage {
    cvtColor(cvImage , cvImage , CV_RGBA2RGB);
    std::vector<cv::Rect> found;
    
    if (!cvImage.empty())
    {
        NSLog(@"large image size is %d * %d\n",cvImage.cols,cvImage.rows);
        cv::Mat largeImage = cvImage.clone();
        double fx = 1;
        double fy = 1;
        resize(largeImage, cvImage, cv::Size(), fx, fy);
        NSLog(@"small image size is %d * %d\n",cvImage.cols,cvImage.rows);
        cv::HOGDescriptor hog;
        hog.setSVMDetector(cv::HOGDescriptor::getDefaultPeopleDetector());
        hog.detectMultiScale(cvImage, found, 0, cv::Size(8,8), cv::Size(8,8), 1.05, 2);
        for(int i=0;i<found.size();i++){
            cv::Rect r=found[i];
            r.x += cvRound(r.width*0.1);
            if(r.x<0)r.x=0;
            r.width = cvRound(r.width*0.8);
            if(r.x>(cvImage.cols-r.width))r.x=(cvImage.cols-r.width);
            r.y += cvRound(r.height*0.07);
            r.height = cvRound(r.height*0.8);
            if(r.y<0)r.y=0;
            if(r.y>(cvImage.rows-r.height))r.y=(cvImage.rows-r.height);
            
            cv::Rect newr(r.tl().x/fx, r.tl().y/fy, r.width/fx, r.height/fy);
            found[i] = newr;
            NSLog(@"rect %d: tl (%d, %d) br (%d, %d)\n",i, newr.tl().x,newr.tl().y, newr.br().x, newr.br().y);
        }
    }
    cvImage.release();
    
    return found;
}

- (std::vector<cv::Rect>) judgeIfPerson: (cv::Mat) cvImage :(std::vector<cv::Rect>) movingObjects {
    std::vector<cv::Rect> persons;
    cvtColor(cvImage , cvImage , CV_RGBA2RGB);
    cv::HOGDescriptor hog;
    hog.setSVMDetector(cv::HOGDescriptor::getDefaultPeopleDetector());
    NSLog(@"Model load");
    std::vector<cv::Rect> foundLocations;
    for (size_t i = 0; i < movingObjects.size(); ++i)
    {
        cv::Rect r = movingObjects[i];
        cv::Mat roi = cvImage(r).clone();
        cv::Mat window;
        cv::resize(roi, window, cv::Size(64, 128));
        hog.detectMultiScale(window, foundLocations, 0, cv::Size(2,2), cv::Size(8,8), 1.05, 2);
        if (!foundLocations.empty())
        {
            persons.push_back(r);
            NSLog(@"rect %zu: tl (%d, %d) br (%d, %d)\n",i, r.tl().x,r.tl().y, r.br().x, r.br().y);
        }
    }
    
    return persons;
}


- (cv::Mat) displayPeds:(cv::Mat) img :(std::vector<cv::Rect>) peds {
    cv::Mat dispImg = img.clone();
    for(int i=0;i<peds.size();i++){
        if(!removed[i]) {
            cv::Rect r = peds[i];
            rectangle(dispImg, r.tl(), r.br(), cv::Scalar(0,255,0),4);
        }
    }
    return dispImg;
}

- (UIImage *) removePedestrian:(NSMutableArray *) indexArray {
    for(int i=0; i<[indexArray count]; i++) {
        [self remove:[[indexArray objectAtIndex:i] intValue]];
    }
    cv::Mat dispImg = [self displayPeds:resultImg :basePeds];
    return MatToUIImage(dispImg);
}

- (UIImage *)remove:(int) index{
    //several steps
    //1. compute homography
    //2. find rectangles that are not intersects or overlap the least
    //3. copy images.
    
    if(index < 0 || index >= basePeds.size()) {
        NSLog(@"Not a pedestrian!");
        return MatToUIImage(baseImg);
    }
    
    cv::Rect rectRemove = basePeds[index];
    NSLog(@"rect %d: tl (%d, %d) br (%d, %d)\n",index, rectRemove.tl().x,rectRemove.tl().y, rectRemove.br().x, rectRemove.br().y);
    
    //small rectangle
    int dx = 50;
    int dy = 50;
    
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
            
            for (int i=0;i<resImgs.size();i++)
            {
                cv::Rect transr = [self homoTransform:smallr :homos[i]];
                
                NSLog(@"check image %d\n",i);
                int mdx = (transr.tl().x + transr.br().x)/2;
                int mdy = (transr.tl().y + transr.br().y)/2;
                if(~(resPedsStack[transr.tl().y][transr.tl().x] | ~(1<<i)) &&
                   ~(resPedsStack[mdy][mdx] | ~(1<<i)) &&
                   ~(resPedsStack[transr.br().y][transr.br().x] | ~(1<<i))) {
                    resImgs[i](transr).copyTo(resultImg(smallr));
                    NSLog(@"Paste from image %d\n",i);
                    break;
                }
            }
        }
    }
    
    
    cv::Mat dispImg = [self displayPeds:resultImg :basePeds];
    return MatToUIImage(dispImg);
}

- (UIImage *) getResultImage {
    return MatToUIImage(resultImg);
}

- (UIImage *) resetResultImage {
    resultImg = baseImg.clone();
    removed.assign(basePeds.size(), false);
    
    cv::Mat dispImg = [self displayPeds:baseImg :basePeds];
    return MatToUIImage(dispImg);
}

//convert cvImage1 to cvImage2
- (cv::Mat) getHomo :(cv::Mat) cvImage1 :(cv::Mat) cvImage2 {
    cvtColor(cvImage1, cvImage1, CV_RGBA2GRAY);
    cvtColor(cvImage2, cvImage2, CV_RGBA2GRAY);
    NSLog(@"image size is w1 %d h1 %d w2 %d h2 %d",cvImage1.cols,cvImage1.rows,cvImage2.cols,cvImage2.rows);
    cv::SiftFeatureDetector* detector=new cv::SiftFeatureDetector(400);
    std::vector<cv::KeyPoint> keypoints_first, keypoints_second;
    cv::SiftDescriptorExtractor extractor;
    cv::Mat descriptor_first,descriptor_second;
    detector->detect(cvImage1,keypoints_first);
    detector->detect(cvImage2,keypoints_second);
    extractor.compute(cvImage1,keypoints_first,descriptor_first);
    extractor.compute(cvImage2, keypoints_second, descriptor_second);
    NSLog(@"feature number is %lu",keypoints_first.size());
    cv::FlannBasedMatcher matcher;
    std::vector<DMatch> matches;
    matcher.match(descriptor_first,descriptor_second,matches);
    
    NSLog(@"hello size is %lu",matches.size());
    double maxdist=0;
    double mindist=100;
    for( int i = 0; i < descriptor_first.rows; i++ )
    {
        double dist = matches[i].distance;
        if( dist < mindist ) mindist = dist;
        if( dist > maxdist ) maxdist = dist;
    }
    std::vector< DMatch > good_matches;
    
    for( int i = 0; i < descriptor_first.rows; i++ )
    {
        if( matches[i].distance < 5*mindist )
        {
            good_matches.push_back( matches[i]);
        }
    }
    std::vector<Point2f> first;
    std::vector<Point2f> second;
    for( int i = 0; i < good_matches.size(); i++ )
    {
        //-- Get the keypoints from the good matches
        first.push_back( keypoints_first[ good_matches[i].queryIdx ].pt );
        second.push_back( keypoints_second[ good_matches[i].trainIdx ].pt );
    }
    cv::Mat outImag;
    drawMatches(cvImage1, keypoints_first, cvImage2, keypoints_second, good_matches, outImag, Scalar::all(-1), Scalar::all(-1));
    //IViewer4.image=MatToUIImage(outImag);
    NSLog(@"good matchsize is %lu",good_matches.size());
    //NSLog(@"Find1 size is %d and find 2 size is %d\n",found1.size(),found2.size());
    Mat H = findHomography(first, second, CV_RANSAC);   //convert first to second
    
    return H;
}

- (cv::Rect) homoTransform: (cv::Rect) r :(cv::Mat) H {
    //apply H to r
    std::vector<cv::Point2f> after;
    std::vector<cv::Point2f> before;
    cv::Point2f* beforetl=new cv::Point2f(r.tl().x,r.tl().y);
    cv::Point2f* beforebr=new cv::Point2f(r.br().x,r.br().y);
    before.push_back(*beforebr);
    before.push_back(*beforetl);
    cv::Point2f* aftertl=new cv::Point2f(0,0);
    cv::Point2f* afterbr=new cv::Point2f(0,0);
    after.push_back(*afterbr);
    after.push_back(*aftertl);
    perspectiveTransform(before, after, H);
    cv::Rect newr(after[1].x,after[1].y,r.width,r.height);
    
    return newr;
}


@end
