//
//  ViewController.m
//  Test1
//
//  Created by wangyf1990 on 3/30/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (CameraDelegateMethods)

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePhoto:(id)sender {
    [self launchCameraControllerFromViewController:self usingDelegate:self];
}

-(BOOL) launchCameraControllerFromViewController: (UIViewController*) controller usingDelegate: (id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate {
    
    BOOL truefalse = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (!truefalse || (delegate == nil) || (controller == nil)) {
        NSLog(@"no can do, delegate/camera/view controller doesn't exist!");
        return NO;
    }
    
    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
    cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    cameraController.allowsEditing = NO;
    cameraController.delegate = delegate;
    [controller presentModalViewController:cameraController animated:YES];
    return YES;
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [picker dismissModalViewControllerAnimated:YES];
}

- (void) imagePickerController: (UIImagePickerController*) picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    // Process for saving an image
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey: UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
    }
    
    // Process for saving a video
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSString *moviePath = [[info objectForKey: UIImagePickerControllerMediaURL] path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
        }
    }
    [picker dismissModalViewControllerAnimated: YES];
    [self.imageView setImage:imageToSave];
}
@end
