//
//  CompressImageManager.m
//  DemoImageCompress
//
//  Created by Logistic Infotech Pvt. Ltd on 16/05/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "CompressImageManager.h"
#import <Photos/Photos.h>
#import <AWSS3.h>
#import "AppDelegate.h"
#import "lblNative.h"

@implementation CompressImageManager

RCT_EXPORT_MODULE()



// Native Components
- (UIView *)view
{
  lblNative *lblTst = [[lblNative alloc] initWithFrame:CGRectMake(16, 50, 250, 50)];
  lblTst.textColor = [UIColor orangeColor];
  lblTst.backgroundColor = [UIColor blackColor];
  lblTst.text = @"Native Label";
  lblTst.textAlignment = NSTextAlignmentCenter;
  return lblTst;
}


// Native Methods
RCT_EXPORT_METHOD(fetchPhotos:(NSString *)imgURL resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  NSBlockOperation *imageblock = [NSBlockOperation blockOperationWithBlock:^{
  
    NSLog(@"local Image URL :====> %@",imgURL);
    
    // Here i have set image size to 600x600 either if width of height will be considered. You can set as per your requirement.
    CGSize retinaSquare = CGSizeMake(600, 600);
    
    PHImageRequestOptions *cropToSquare = [[PHImageRequestOptions alloc] init];
    cropToSquare.resizeMode = PHImageRequestOptionsResizeModeExact;
    cropToSquare.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    [cropToSquare setSynchronous:YES];
    
    NSURL *imageurl = [NSURL URLWithString:imgURL];
    
    PHFetchResult* asset =[PHAsset fetchAssetsWithALAssetURLs:[NSArray arrayWithObjects:imageurl, nil] options:nil];
    
    [[PHImageManager defaultManager] requestImageForAsset:(PHAsset *)[asset objectAtIndex:0] targetSize:retinaSquare contentMode:PHImageContentModeAspectFit                                                options:cropToSquare                                          resultHandler:^(UIImage *fetchedImage, NSDictionary *info) {
      
      // Below code is for image quality optimisation because original image may be very large in size so we need to optimise image to upload and use with our app for best user experience. You can set below value as per you requirements
      NSData *imageData = UIImageJPEGRepresentation(fetchedImage,0.65);
      
      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
      NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
      NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%0.0f.jpg", timeStamp*1000]];
      NSError *error = nil;
      [imageData writeToFile:filePath options:NSDataWritingAtomic error:&error];
      NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
      if(error){
        fileUrl = imageurl;
      }
      
      NSString * S3BucketName = @"AWSBucketName";
      
      NSString * remoteName = [NSString stringWithFormat:@"image%ld%@", (long)(timeStamp * 1000), @".jpg"];
      
      AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
      uploadRequest.bucket = S3BucketName;
      uploadRequest.key = remoteName;
      uploadRequest.body =fileUrl;
      uploadRequest.contentType = @"image/jpeg";
      // Set permission on S3 bucket as per your requirements
      uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
      
      AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
      [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
          if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
            switch (task.error.code) {
              case AWSS3TransferManagerErrorCancelled:
                NSLog(@"Upload failed From Cancelled: [%@]", task.error);
                break;
                
              case AWSS3TransferManagerErrorPaused:
                NSLog(@"Upload failed From Paused: [%@]", task.error);
                break;
                
              default:
                NSLog(@"Upload failed: [%@]", task.error);
                break;
            }
          } else {
            NSLog(@"Upload failed: [%@]", task.error);
          }
          resolve(nil);
        }
        
        if (task.result) {
          //            NSLog(@"Task Result :=====> %@",task.result);
          
          NSString *strurl = [AWSS3.defaultS3.configuration.endpoint.URL absoluteString];
          NSString *strImageUrl = [strurl stringByAppendingPathComponent:uploadRequest.bucket];
          strImageUrl = [strImageUrl stringByAppendingPathComponent:uploadRequest.key];
          //            NSLog(@"Uploaded url : %@", strImageUrl);
          
          if(strImageUrl != nil && ![strImageUrl isEqualToString:@""])
          {
            NSLog(@"Upload Image URL :====> %@",strImageUrl);
            resolve(strImageUrl);
          }
          else {
            resolve(@"");
          }
        }
        return nil;
      }];
      
    }];
  }];
  
  // Add block in queue
    [[AppDelegate sharedAppDelegate].queue addOperation:imageblock];
}

@end
