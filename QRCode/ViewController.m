//
//  ViewController.m
//  QRCode
//
//  Created by iuimini5 on 2015/5/5.
//  Copyright (c) 2015年 iuimini5. All rights reserved.
//

#import "ViewController.h"
#import "SCShapeView.h"
@interface ViewController (){
    AVCaptureDevice *device;
}
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic,strong) SCShapeView *boundingBox;
@property (nonatomic,strong) NSTimer *boxHideTimer;
@property (weak, nonatomic) IBOutlet UILabel *Label;
@end

@implementation ViewController
@synthesize videoCamera;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _session = [[AVCaptureSession alloc] init];
    
    _session = [[AVCaptureSession alloc] init];
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    
    // Display full screen
    _previewLayer.frame = CGRectMake(0,0,720,960);
    
    // Add the video preview layer to the view
    [self.view.layer addSublayer:_previewLayer];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (input) {
        [_session addInput:input];
    } else {
        NSLog(@"Error: %@", error);
    }
    if ([videoCamera.captureSession canAddInput:input]){
        [videoCamera.captureSession addInput:input];
    }    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:output];
    
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code]];
    
    [_session startRunning];
    _boundingBox = [[SCShapeView alloc] initWithFrame:self.view.bounds];
    _boundingBox.backgroundColor = [UIColor clearColor];
    _boundingBox.hidden = YES;
    [self.view addSubview:_boundingBox];
//    if ([device lockForConfiguration:&error])
//    {
//        [device setFocusModeLockedWithLensPosition:0.57 completionHandler:nil];
//    }
//    [videoCamera lockFocus];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    NSString *QRCode = nil;
    NSArray *corner = nil;
    
    for (AVMetadataObject *metadata in metadataObjects) {
//        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            // Transform the meta-data coordinates to screen coords
            AVMetadataMachineReadableCodeObject *transformed = (AVMetadataMachineReadableCodeObject *)[_previewLayer transformedMetadataObjectForMetadataObject:metadata];
            // Update the frame on the _boundingBox view, and show it
            _boundingBox.frame = transformed.bounds;
            _boundingBox.hidden = NO;
            // Now convert the corners array into CGPoints in the coordinate system
            //  of the bounding box itself
            NSArray *translatedCorners = [self translatePoints:transformed.corners
                                                      fromView:self.view
                                                        toView:_boundingBox];
            // Set the corners array
            [self startOverlayHideTimer];
            _boundingBox.corners = translatedCorners;
            QRCode = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            corner = [(AVMetadataMachineReadableCodeObject *)metadata corners];
            break;
        }
        NSLog(@"QR Code: %@", QRCode);
    self.Label.text= QRCode;
//    }
//    [_session stopRunning];
//    [_previewLayer removeFromSuperlayer];
    
    
    NSLog(@"QR Corner: %@", corner[0]);
//    NSLog(@"Focus:%f",device.lensPosition);
}
- (NSArray *)translatePoints:(NSArray *)points fromView:(UIView *)fromView toView:(UIView *)toView
{
    NSMutableArray *translatedPoints = [NSMutableArray new];
    
    // The points are provided in a dictionary with keys X and Y
    for (NSDictionary *point in points) {
        // Let's turn them into CGPoints
        CGPoint pointValue = CGPointMake([point[@"X"] floatValue], [point[@"Y"] floatValue]);
        // Now translate from one view to the other
        CGPoint translatedPoint = [fromView convertPoint:pointValue toView:toView];
        // Box them up and add to the array
        [translatedPoints addObject:[NSValue valueWithCGPoint:translatedPoint]];
    }
    
    return [translatedPoints copy];
}
- (void)startOverlayHideTimer
{
    // Cancel it if we're already running
    if(_boxHideTimer) {
        [_boxHideTimer invalidate];
    }
    
    // Restart it to hide the overlay when it fires
    _boxHideTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                     target:self
                                                   selector:@selector(removeBoundingBox:)
                                                   userInfo:nil
                                                    repeats:NO];
}
- (void)removeBoundingBox:(id)sender
{
    // Hide the box and remove the decoded text
    _boundingBox.hidden = YES;
//    _decodedMessage.text = @"";
}
@end
