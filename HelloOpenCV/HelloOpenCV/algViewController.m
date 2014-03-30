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
@synthesize IViewer;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    image = [UIImage imageNamed:@"9.jpg"];
    if (image != nil)
        IViewer.image=image;
    cv::Mat cvImage;
    UIImageToMat(image, cvImage);
    cvtColor(cvImage , cvImage , CV_RGBA2RGB);
    if (!cvImage.empty())
    {
        //printf();
        cv::HOGDescriptor hog;
        hog.setSVMDetector(cv::HOGDescriptor::getDefaultPeopleDetector());
        std::vector<cv::Rect> found;
        hog.detectMultiScale(cvImage, found, 0.2, cv::Size(8,8), cv::Size(1024,1024), 1.05, 2);
        for(int i=0;i<found.size();i++){
            cv::Rect r=found[i];
            rectangle(cvImage, r.tl(), r.br(), cv::Scalar(0,255,0),3);
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
        IViewer.image=MatToUIImage(cvImage);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
