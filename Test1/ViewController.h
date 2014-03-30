//
//  ViewController.h
//  Test1
//
//  Created by wangyf1990 on 3/30/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (IBAction)takePhoto:(id)sender;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;


@end
