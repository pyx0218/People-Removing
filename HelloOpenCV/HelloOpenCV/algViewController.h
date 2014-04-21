//
//  algViewController.h
//  HelloOpenCV
//
//  Created by Taikun Liu on 3/11/14.
//  Copyright (c) 2014 Taikun Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface algViewController : UIViewController{
    UIImage* image1;
    UIImage* image2;
    UIImage* image3;
    UIImage* image4;
    UIImage* image5;
    UIImage* image6;
    UIImage* image7;
    UIImage* image8;
    
    IBOutlet UITextField *indexvalue;
    
}
@property (strong, nonatomic) IBOutlet UIImageView *IViewer1;
@property (strong, nonatomic) IBOutlet UIImageView *IViewer2;
@property (strong, nonatomic) IBOutlet UIImageView *IViewer3;
@property (strong, nonatomic) IBOutlet UIImageView *IViewer4;
@property (strong, nonatomic) IBOutlet UIImageView *IViewer5;
@property (strong, nonatomic) IBOutlet UIImageView *IViewer6;
@property (strong, nonatomic) IBOutlet UIImageView *IViewer7;
@property (strong, nonatomic) IBOutlet UIImageView *IViewer8;
@property (strong, nonatomic) IBOutlet UIImageView *IViewer9;

- (IBAction)RecognitionPressed;
- (IBAction)DetectMovingPressed;
- (IBAction)DetectPedestrianPressed;
- (IBAction)RemovePressed;
- (IBAction)donePressed;
- (IBAction)cancelPressed;

@end
