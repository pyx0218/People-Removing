//
//  algViewController.m
//  HelloOpenCV
//
//  Created by Taikun Liu on 3/11/14.
//  Copyright (c) 2014 Taikun Liu. All rights reserved.
//

#import "algViewController.h"
#import "opencv2/highgui/ios.h"
#include "opencv2/core/core.hpp"
#include "opencv2/features2d/features2d.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/calib3d/calib3d.hpp"
#include "opencv2/nonfree/nonfree.hpp"

@interface algViewController ()

@end

@implementation algViewController
using namespace cv;
@synthesize IViewer1;
@synthesize IViewer2;
@synthesize IViewer3;
@synthesize IViewer4;


- (void)viewDidLoad
{
    [super viewDidLoad];
    std::vector<cv::Rect> found1;
    std::vector<cv::Rect> found2;

	// Do any additional setup after loading the view, typically from a nib.
    image1 = [UIImage imageNamed:@"IMG_0214.jpg"];
    cv::Mat cvImageLarge;
    UIImageToMat(image1, cvImageLarge);
    
    int srows=(int)(cvImageLarge.rows);
    int scols=(int)(cvImageLarge.cols);
    cv::Mat cvImage(srows,scols,CV_64FC3);
    resize(cvImageLarge, cvImage, cvImage.size());
    cvtColor(cvImage , cvImage , CV_RGBA2RGB);
    
    if (!cvImage.empty())
    {
        cv::HOGDescriptor hog;
        NSLog(@"start load svm");
        hog.setSVMDetector(cv::HOGDescriptor::getDefaultPeopleDetector());
        NSLog(@"Start detect people");
        hog.detectMultiScale(cvImage, found1, 0, cv::Size(8,8), cv::Size(0,0), 1.1, 2);
        for(int i=0;i<found1.size();i++){
            // cv::Rect r=found2[i];
            found1[i].x += cvRound(found1[i].width*0.1);
            if(found1[i].x<0)found1[i].x=0;
            found1[i].width = cvRound(found1[i].width*0.8);
            if(found1[i].x>(cvImage.cols-found1[i].width))found1[i].x=(cvImage.cols-found1[i].width);
            found1[i].y += cvRound(found1[i].height*0.07);
            found1[i].height = cvRound(found1[i].height*0.8);
            if(found1[i].y<0)found1[i].y=0;
            if(found1[i].y>(cvImage.rows-found1[i].height))found1[i].y=(cvImage.rows-found1[i].height);
            rectangle(cvImage, found1[i].tl(), found1[i].br(), cv::Scalar(0,255,0),3);
             NSLog(@"#########rect %d : x is %d, y is %d, width is %d, height is %d\n",i,found1[i].x,found1[i].y,found1[i].width,found1[i].height);
           
        }
        //NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];
        IViewer1.image=MatToUIImage(cvImage);
    }
    NSLog(@"End detect people");
    ////image2
    image2 = [UIImage imageNamed:@"IMG_0217.jpg"];
    UIImageToMat(image2, cvImage);
    cvtColor(cvImage , cvImage , CV_RGBA2RGB);
    if (!cvImage.empty())
    {
        cv::HOGDescriptor hog;
        hog.setSVMDetector(cv::HOGDescriptor::getDefaultPeopleDetector());
        hog.detectMultiScale(cvImage, found2, 0, cv::Size(8,8), cv::Size(10,10), 1.2, 2);
        for(int i=0;i<found2.size();i++){
           // cv::Rect r=found2[i];
            found2[i].x += cvRound(found2[i].width*0.1);if(found2[i].x<0)found2[i].x=0;
            found2[i].width = cvRound(found2[i].width*0.8);
            found2[i].y += cvRound(found2[i].height*0.07);
            found2[i].height = cvRound(found2[i].height*0.8);
            rectangle(cvImage, found2[i].tl(), found2[i].br(), cv::Scalar(0,255,0),3);
           
        }
        IViewer2.image=MatToUIImage(cvImage);
    }
    cvImage.release();
    cv::Mat cvImage1h;
    UIImageToMat(image1, cvImage1h);
    cv::Mat cvImage2h;
    UIImageToMat(image2, cvImage2h);
       //several steps
    //1. compute homography
    cvtColor(cvImage1h , cvImage1h , CV_RGBA2GRAY);
    cvtColor(cvImage2h , cvImage2h , CV_RGBA2GRAY);
    NSLog(@"image size is w1 %d h1 %d w2 %d h2 %d",cvImage1h.cols,cvImage1h.rows,cvImage2h.cols,cvImage2h.rows);
    cv::SiftFeatureDetector* detector=new SiftFeatureDetector(400);
    std::vector<KeyPoint> keypoints_first, keypoints_second;
    cv::SiftDescriptorExtractor extractor;
    cv::Mat descriptor_first,descriptor_second;
    detector->detect(cvImage1h,keypoints_first);
    detector->detect(cvImage2h,keypoints_second);
    extractor.compute(cvImage1h,keypoints_first,descriptor_first);
    extractor.compute(cvImage2h, keypoints_second, descriptor_second);
    NSLog(@"feature number is %d",keypoints_first.size());
    FlannBasedMatcher matcher;
    std::vector<DMatch> matches;
    matcher.match(descriptor_first,descriptor_second,matches);
    
    NSLog(@"hello size is %d",matches.size());
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
    drawMatches(cvImage1h, keypoints_first, cvImage2h, keypoints_second, good_matches, outImag, Scalar::all(-1), Scalar::all(-1));
    IViewer4.image=MatToUIImage(outImag);
    NSLog(@"good matchsize is %d",good_matches.size());
    NSLog(@"Find1 size is %d and find 2 size is %d\n",found1.size(),found2.size());
    Mat H = findHomography( second, first, CV_RANSAC );//convert second to first
 //   Mat Hinv=H.inv(DECOMP_SVD);
    Mat Hinv=findHomography( first, second, CV_RANSAC );
  //  NSLog(@"H is");
   // std::cout<<H<<std::endl;
    cvImage1h.release();
    cvImage2h.release();
    cv::Mat cvImage1;
    UIImageToMat(image1, cvImage1);
    cv::Mat cvImage2;
    UIImageToMat(image2, cvImage2);
    //2. find rectangles that are not intersects
    //3. copy images.
    for (int i=0;i<found1.size();i++)
    {
        cv:: Rect r1=found1[i];
        bool interb=false;
        for(int j=0;j<found2.size();j++)
        {
            //apply H to r2
            cv::Rect r2=found2[j];
            std::vector<cv::Point2f> after;
            std::vector<cv::Point2f> before;
            cv::Point2f* beforetl=new cv::Point2f(r2.tl().x,r2.tl().y);
            cv::Point2f* beforebr=new cv::Point2f(r2.br().x,r2.br().y);
            before.push_back(*beforebr);
            before.push_back(*beforetl);
            cv::Point2f* aftertl=new cv::Point2f(0,0);
            cv::Point2f* afterbr=new cv::Point2f(0,0);
            after.push_back(*afterbr);
            after.push_back(*aftertl);
         //   cv::Mat *beforrec = new cv::Mat(2,2,CvType.CV_32FC2);
          //  cv::Mat *afterrec = new cv::Mat(2,2,CvType.CV_32FC2);
            perspectiveTransform(before, after, H);
          //  NSLog(@"after perspective");
         //   std::cout<<before<<std::endl;
         //   std::cout<<after[0] <<std::endl;
         //   std::cout<<after[1] <<std::endl;
            cv::Rect r3(after[1].x,after[1].y,after[0].x-after[1].x,after[0].y-after[1].y);
            cv::Rect inter=r1&r3;
        //    std::cout<<r1<<std::endl;
        //    std::cout<<r3<<std::endl;
        //    std::cout<<inter<<std::endl;
            if(inter.width!=0)
            {
                //copy content from img2 to img1
                interb=true;
            }
        }
        if(!interb)
        {
            //apply Hinv to r1
            std::vector<cv::Point2f> after;
            std::vector<cv::Point2f> before;
            cv::Point2f* beforetl=new cv::Point2f(r1.tl().x,r1.tl().y);
            cv::Point2f* beforebr=new cv::Point2f(r1.br().x,r1.br().y);
            before.push_back(*beforebr);
            before.push_back(*beforetl);
            cv::Point2f* aftertl=new cv::Point2f(0,0);
            cv::Point2f* afterbr=new cv::Point2f(0,0);
            after.push_back(*afterbr);
            after.push_back(*aftertl);
            perspectiveTransform(before, after, Hinv);
           // NSLog(@"after apply hinv to r1");
            std::cout<<before<<std::endl;
            if(after[1].x<0)after[1].x=0;
            if(after[1].y<0)after[1].y=0;
            if(after[0].x>cvImage2.cols)after[0].x=cvImage2.cols;
            if(after[0].y>cvImage2.rows)after[0].y=cvImage2.cols;
             std::cout<<after<<std::endl;
        //    if((after[1].x-after[0].x)<0 || (after[1].y-after[0].y)<0)break;
          //  else{
                cv::Rect r1a(after[1].x,after[1].y,r1.width,r1.height);
                std::cout<<r1a<<std::endl;
                cvImage2(r1a).copyTo(cvImage1(r1));
               // NSLog(@"#######################################################Replaced");
           // }
            
            //start to blur the boundaries of r1 in cvimage1
          /*  int topx=r1.x-cvRound((r1.width*0.2));
            int topy=r1.y-cvRound((r1.height*0.2));
            cv::Mat tbar=cvImage1(cv::Rect(topx,topy,r1.width*1.4,120));
            cv::Mat bbar=cvImage1(cv::Rect(topx,r1.y+r1.height*0.8,r1.width*1.4,120));
            cv::Mat lbar=cvImage1(cv::Rect(topx,topy,120,r1.height*1.4));
            cv::Mat rbar=cvImage1(cv::Rect(r1.x+r1.width*0.8,topy,120,r1.height*1.4));
            for ( int i = 1; i < 16; i = i + 4 )
            {
                medianBlur( cvImage1(cv::Rect(topx,topy,r1.width*1.4,120)), tbar, i );
                medianBlur( cvImage1(cv::Rect(topx,r1.y+r1.height*0.8,r1.width*1.4,120)), bbar, i);
                medianBlur( cvImage1(cv::Rect(topx,topy,120,r1.height*1.4)), lbar, i );
                medianBlur( cvImage1(cv::Rect(r1.x+r1.width*0.8,topy,120,r1.height*1.4)), rbar, i);
            }
            tbar.copyTo(cvImage1(cv::Rect(topx,topy,r1.width*1.4,120)));
            bbar.copyTo(cvImage1(cv::Rect(topx,r1.y+r1.height*0.8,r1.width*1.4,120)));
            lbar.copyTo(cvImage1(cv::Rect(topx,topy,120,r1.height*1.4)));
            rbar.copyTo(cvImage1(cv::Rect(r1.x+r1.width*0.8,topy,120,r1.height*1.4)));*/
            cv::Rect rRec1=cv::Rect(r1.x+r1.width-10,r1.y-10,40,r1.height+10);
            int weights[40]={5,5,5,5,5,5,5,5,5,5,5,5,5,5,4,4,4,4,4,4,4,4,3,3,3,3,3,3,2,2,2,2,2,1,1,1,1,1,1};
            cv::Mat result(r1.height+20,40,cvImage1.type());
        //    std::cout<<result.rows+" and "+result.cols<<std::endl;
            for(int i=1;i<r1.height+20;i++)
            {
                
                uchar* rowi2 = cvImage2.ptr/*<uchar>*/(r1.y-10+i);
                std::cout<<i<<std::endl;
                uchar* rowi1 = cvImage1.ptr/*<uchar>*/(r1a.y-10+i);
                std::cout<<i<<std::endl;
                uchar* rowir = result.ptr/*<uchar>*/(i);
                std::cout<<i<<std::endl;
                for(int j=0;j<40;j++)
                {
                    std::cout<<j;
                    rowi1[r1.x+r1.width-10+j]=(rowi2[r1.x+r1.width-10+j]*weights[j]+rowi1[r1.x+r1.width-10+j])/(weights[j]+1);
                }
            }
            //IViewer5.image=MatToUIImage(result);
          //  std::cout<<"before copy"<<std::endl;
            //result(cv::Rect(0,0,40,r1.height+20)).copyTo(cvImage1(rRec1));
            
        }

    }
    NSLog(@"before release");
    cvImage2.release();
    IViewer3.image=MatToUIImage(cvImage1);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*  cv::Mat gray;
 // Convert the image to grayscale
 cv::cvtColor(cvImage, gray, CV_RGBA2GRAY);
 // Apply Gaussian filter to remove small edges
 cv::GaussianBlur(gray, gray,
 cv::Size(5, 5), 1.2, 1.2);
 // Calculate edges with Canny
 cv::Mat edges;
 cv::Canny(gray, edges, 0, 50);
 // Fill image with white color
 cvImage.setTo(cv::Scalar::all(255));
 // Change color on edges
 cvImage.setTo(cv::Scalar(0, 128, 255, 255), edges);
 // Convert cv::Mat to UIImage* and show the resulting image
 IViewer.image = MatToUIImage(cvImage);*/

//perspectiveTransform(r2.br(), afterbr, H);

/*  cv:: Rect r2=found2[j];
 cv::Point tl2=r2.tl();
 cv::Point br2=r2.br();
 double cx2=(tl2.x+br2.x)/(double)2;
 double cy2=(tl2.y+br2.y)/2.0;
 int w2=(br2.x-tl2.x);
 int h2=(br2.y-tl2.y);
 double xdiff=fabs(cx1-cx2);
 double ydiff=fabs(cy1-cy2);
 NSLog(@"rectangle j is %d x is %f y is %f w is %d h is %d\n brx is %d and bry is %d \n",j,cx2,cy2,w2,h2,br2.x,br2.y);
 
 if(xdiff>=(w1+w2)/2 || ydiff >=(h1+h2)/2)//The two rectangles do not intersect*/
@end
