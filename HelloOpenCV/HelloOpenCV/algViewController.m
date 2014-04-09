//
//  algViewController.m
//  HelloOpenCV
//
//  Created by Taikun Liu on 3/11/14.
//  Copyright (c) 2014 Taikun Liu. All rights reserved.
//

#import "algViewController.h"
#import "opencv2/highgui/ios.h"
@interface algViewController ()

@end

@implementation algViewController
using namespace cv;
@synthesize IViewer1;
@synthesize IViewer2;
@synthesize IViewer3;
@synthesize IViewer4;
@synthesize IViewer5;
@synthesize IViewer6;
@synthesize IViewer7;
@synthesize IViewer8;
@synthesize IViewer9;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSMutableArray *images = [[NSMutableArray alloc] init];
    [images addObject:[UIImage imageNamed:@"IMG_0184.jpg"] ];
    [images addObject:[UIImage imageNamed:@"IMG_0185.jpg"] ];
    [images addObject:[UIImage imageNamed:@"IMG_0186.jpg"] ];
    [images addObject:[UIImage imageNamed:@"IMG_0187.jpg"] ];
    [images addObject:[UIImage imageNamed:@"IMG_0188.jpg"] ];
    //[images addObject:[UIImage imageNamed:@"IMG_0216.jpg"] ];
    //[images addObject:[UIImage imageNamed:@"IMG_0217.jpg"] ];
    //[images addObject:[UIImage imageNamed:@"IMG_0268.jpg"] ];

    NSLog(@"%d\n",[images count]);
    
    NSMutableArray *iviewers = [[NSMutableArray alloc] init];
    [iviewers addObject:IViewer1];
    [iviewers addObject:IViewer2];
    [iviewers addObject:IViewer3];
    [iviewers addObject:IViewer4];
    [iviewers addObject:IViewer5];
    [iviewers addObject:IViewer6];
    [iviewers addObject:IViewer7];
    [iviewers addObject:IViewer8];
    [iviewers addObject:IViewer9];
    NSLog(@"%d\n",[iviewers count]);
    
    cv::Mat baseImg;
    std::vector<cv::Rect> basePeds;
    std::vector<cv::Mat> resImgs;
    std::vector<std::vector<cv::Rect>> resPeds;
    
    for(int i=0; i<[images count]; i++) {
        //Display original image
        UIImageView *iviewer = [iviewers objectAtIndex:i];
        UIImage *img = [images objectAtIndex:i];
        iviewer.image = img;
        
        //Recognize pedestrians
        cv::Mat cvImage;
        UIImageToMat(img, cvImage);
        std::vector<cv::Rect> found = [self pedestrianRec:cvImage];
        
        //Display pedestrian rectangles
        cv::Mat dispImg = [self displayPeds:cvImage :found];
        iviewer.image = MatToUIImage(dispImg);
        
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
    
    for(int i=0; i<basePeds.size(); i++) {
        [self removePedestrian:baseImg :basePeds :i :resImgs :resPeds];
    }
    
    IViewer9.image = MatToUIImage(baseImg);
}

- (cv::Mat) displayPeds:(cv::Mat) img :(std::vector<cv::Rect>) peds {
    cv::Mat dispImg = img.clone();
    for(int i=0;i<peds.size();i++){
        cv::Rect r = peds[i];
        rectangle(dispImg, r.tl(), r.br(), cv::Scalar(0,255,0),4);
    }
    return dispImg;
}

- (void)removePedestrian:(cv::Mat) baseImg :(std::vector<cv::Rect>) basePeds :(int) index :(std::vector<cv::Mat>) resImgs :(std::vector<std::vector<cv::Rect>>) resPeds{
    //several steps
    //1. compute homography
    //2. find rectangles that are not intersects
    //3. copy images.
    cv::Rect rectRemove = basePeds[index];
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
            for (int i=0;i<resImgs.size();i++)
            {
                cv::Mat cvImg = resImgs[i];
                std::vector<cv::Rect> peds = resPeds[i];
                bool interb=false;
                for(int j=0; j<peds.size(); j++) {
                    cv::Rect rectReplace = peds[j];
                    cv::Rect inter = smallr & rectReplace;
                    if(inter.width!=0)
                    {
                        interb=true;
                        //copy content from img2 to img1
                        //NSLog(@"rectangle i is %d tx is %d ty is %d w is %d h is %d\n bx is %d and by is %d \n",i,r2.tl().x,r2.tl().y,r2.width,r2.height,r2.br().x,r2.br().y);
                    }
                }
                if(!interb)
                {
                    cvImg(smallr).copyTo(baseImg(smallr));
                    break;
                }
            }
        }
    }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
