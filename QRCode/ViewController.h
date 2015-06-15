//
//  ViewController.h
//  QRCode
//
//  Created by iuimini5 on 2015/5/5.
//  Copyright (c) 2015年 iuimini5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
@import AVFoundation;
@interface ViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>
{
    CvVideoCamera* videoCamera;
    __weak IBOutlet UILabel *label;
    
}
@property (nonatomic,retain) CvVideoCamera* videoCamera;

@end

