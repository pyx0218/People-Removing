//
//  algViewController.m
//  HelloOpenCV
//
//  Created by Taikun Liu on 3/11/14.
//  Copyright (c) 2014 Taikun Liu. All rights reserved.
//

#import "algViewController.h"
#import "opencv2/highgui/ios.h"
#import "RemoveHelper.h"
@interface algViewController ()

@end

@implementation algViewController

@synthesize IViewer1;
@synthesize IViewer2;
@synthesize IViewer3;
@synthesize IViewer4;
@synthesize IViewer5;
@synthesize IViewer6;
@synthesize IViewer7;
@synthesize IViewer8;
@synthesize IViewer9;

RemoveHelper *r;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSMutableArray *images = [[NSMutableArray alloc] init];
//    [images addObject:[UIImage imageNamed:@"IMG_0184.jpg"] ];
//    [images addObject:[UIImage imageNamed:@"IMG_0185.jpg"] ];
//    [images addObject:[UIImage imageNamed:@"IMG_0186.jpg"] ];
//    [images addObject:[UIImage imageNamed:@"IMG_0187.jpg"] ];
//    [images addObject:[UIImage imageNamed:@"IMG_0188.jpg"] ];
    [images addObject:[UIImage imageNamed:@"IMG_0214.jpg"] ];
    [images addObject:[UIImage imageNamed:@"IMG_0215.jpg"] ];
    [images addObject:[UIImage imageNamed:@"IMG_0216.jpg"] ];
    [images addObject:[UIImage imageNamed:@"IMG_0217.jpg"] ];
//    [images addObject:[UIImage imageNamed:@"IMG_0262.jpg"] ];
//    [images addObject:[UIImage imageNamed:@"IMG_0263.jpg"] ];
//    [images addObject:[UIImage imageNamed:@"IMG_0264.jpg"] ];
//    [images addObject:[UIImage imageNamed:@"IMG_0265.jpg"] ];
//    [images addObject:[UIImage imageNamed:@"IMG_0266.jpg"] ];
//    [images addObject:[UIImage imageNamed:@"IMG_0267.jpg"] ];
//    [images addObject:[UIImage imageNamed:@"IMG_0268.jpg"] ];
    
    NSLog(@"%d\n",[images count]);
    
//    NSMutableArray *iviewers = [[NSMutableArray alloc] init];
//    [iviewers addObject:IViewer1];
//    [iviewers addObject:IViewer2];
//    [iviewers addObject:IViewer3];
//    [iviewers addObject:IViewer4];
//    [iviewers addObject:IViewer5];
//    [iviewers addObject:IViewer6];
//    [iviewers addObject:IViewer7];
//    [iviewers addObject:IViewer8];
//    [iviewers addObject:IViewer9];
//    NSLog(@"%d\n",[iviewers count]);
    
    r = [[RemoveHelper alloc] initWithImages:images];
    IViewer1.image = [images objectAtIndex:0];
    
}

- (IBAction)RecognitionPressed {
    [r doRecognition];
    UIImage *img = [r getBaseImg];
    IViewer1.image = img;
}

- (IBAction)DetectMovingPressed {
    
}

- (IBAction)DetectPedestrianPressed {
    [r detectPedestrian];
    UIImage *img = [r getBaseImg];
    IViewer1.image = img;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    CGPoint point = [aTouch locationInView:aTouch.view];
    NSLog(@"%f, %f\n", point.x, point.y);
    //UIImage *img = [r removePedestrian:point.x :point.y];
    //IViewer1.image = img;
    // point.x and point.y have the coordinates of the touch
}

- (IBAction)RemovePressed {
    int index = [indexvalue.text intValue];
    UIImage *img = [r remove:index];
    IViewer1.image = img;
}

- (IBAction)donePressed {
    UIImage *img = [r getResultImage];
    IViewer1.image = img;
}

- (IBAction)cancelPressed {
    UIImage *img = [r resetResultImage];
    IViewer1.image = img;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
