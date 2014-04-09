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
    
    IBOutlet UITextField *xvalue;
    IBOutlet UITextField *yvalue;
    
}
@property (weak, nonatomic) IBOutlet UIImageView *IViewer1;
@property (weak, nonatomic) IBOutlet UIImageView *IViewer2;
@property (weak, nonatomic) IBOutlet UIImageView *IViewer3;
@property (weak, nonatomic) IBOutlet UIImageView *IViewer4;
@property (weak, nonatomic) IBOutlet UIImageView *IViewer5;
@property (weak, nonatomic) IBOutlet UIImageView *IViewer6;
@property (weak, nonatomic) IBOutlet UIImageView *IViewer7;
@property (weak, nonatomic) IBOutlet UIImageView *IViewer8;
@property (weak, nonatomic) IBOutlet UIImageView *IViewer9;

- (IBAction)RecognitionPressed;
- (IBAction)RemovePressed;
- (IBAction)donePressed;
- (IBAction)cancelPressed;

@end
