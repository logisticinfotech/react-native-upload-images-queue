File upload is an essential aspect of any project. Given this importance, it is surprising that many developers face challenges of adding file upload feature to their projects, specially while they have to deal with multiple image upload and project is mostly related to images.

Specifically for mobile application we need to take care of memory being used by application and while we have number of images being uploaded from mobile application.

Here I have created native iOS module with my React Native code because of react-native-photo framework not allowing me to fetch resized image directly so I have to accomplish that using native code here you will get all detail about [this blog](https://www.logisticinfotech.com/blog/react-native-import-resized-image-photo-gallery). Generally we are using mostly using S3 bucket for file uploading so I have used that you may use your own server too as per your requirements.

Actually S3 bucket allow single image upload in single call but I have number of images to upload to S3. To accomplish this I have used queue feature of native which will simplify uploading process in background without holding much more memory of device.

Here is some detail code about AWS configuaration needed

```
AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:accessKey secretKey:secretKey];
 
AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider]; 
 
  configuration.timeoutIntervalForRequest = 3000;
 
  configuration.timeoutIntervalForResource = 180;
 
  configuration.maxRetryCount = 3;
 
  [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
 
// Common queue initialisation
 
 
 
  self.queue = [[NSOperationQueue alloc] init];
 
  self.queue.maxConcurrentOperationCount = 1;
 
  [self.queue waitUntilAllOperationsAreFinished];
```

Here you will find detail code of how to upload images by queue.

```
NSBlockOperation *imageblock = [NSBlockOperation blockOperationWithBlock:^{
    // Here i have set image size to 600×600 either if width of height will be considered. You can set as per your requirement.
    CGSize retinaSquare = CGSizeMake(600, 600);
 
 
    PHImageRequestOptions *cropToSquare = [[PHImageRequestOptions alloc] init];
 
    cropToSquare.resizeMode = PHImageRequestOptionsResizeModeExact;
 
    cropToSquare.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
 
    [cropToSquare setSynchronous:YES];
 
    NSURL *imageurl = [NSURL URLWithString:imgURL];
 
    PHFetchResult* asset =[PHAsset fetchAssetsWithALAssetURLs:[NSArray arrayWithObjects:imageurl, nil] options:nil];
 
    [[PHImageManager defaultManager] requestImageForAsset:(PHAsset *)[asset objectAtIndex:0] targetSize:retinaSquare contentMode:PHImageContentModeAspectFit                                                options:cropToSquare                                          resultHandler:^(UIImage *fetchedImage, NSDictionary *info)
 
      // Below code is for image quality optimisation because original image may be very large in size so we need to optimise image to upload and use with our app for best user experience. You can set below value as per you requirements
 
      NSData *imageData = UIImageJPEGRepresentation(fetchedImage,0.65);
 
      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
 
      NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
 
      NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@”%0.0f.jpg”, timeStamp*1000]];
 
      NSError *error = nil;
 
      [imageData writeToFile:filePath options:NSDataWritingAtomic error:&error];
 
      NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
 
      if(error){
 
        fileUrl = imageurl;
 
      }
 
      NSString * S3BucketName = @”AWSBucketName”;
 
      NSString * remoteName = [NSString stringWithFormat:@”image%ld%@”, (long)(timeStamp * 1000), @”.jpg”];
 
      AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
 
      uploadRequest.bucket = S3BucketName;
 
      uploadRequest.key = remoteName;
 
      uploadRequest.body =fileUrl;
 
      uploadRequest.contentType = @”image/jpeg”;
 
      // Set permission on S3 bucket as per your requirements
 
      uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
 
      AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
 
      [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
 
        if (task.error) {
 
          if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
 
            switch (task.error.code) {
 
              case AWSS3TransferManagerErrorCancelled:
 
                NSLog(@”Upload failed From Cancelled: [%@]”, task.error);
 
                break;
 
              case AWSS3TransferManagerErrorPaused:
 
                NSLog(@”Upload failed From Paused: [%@]”, task.error);
 
                break;
 
              default:
 
                NSLog(@”Upload failed: [%@]”, task.error);
 
                break;
 
            }
 
          } else {
 
            NSLog(@”Upload failed: [%@]”, task.error);
 
          }
 
          resolve(nil);
 
        }
 
        if (task.result) {
 
          NSString *strurl = [AWSS3.defaultS3.configuration.endpoint.URL absoluteString];
 
          NSString *strImageUrl = [strurl stringByAppendingPathComponent:uploadRequest.bucket];
 
          strImageUrl = [strImageUrl stringByAppendingPathComponent:uploadRequest.key];
 
          if(strImageUrl != nil && ![strImageUrl isEqualToString:@””])
 
          {
 
            NSLog(@”Upload Image URL :====> %@”,strImageUrl);
 
            resolve(strImageUrl);
 
          }
 
          else {
 
            resolve(@””);
 
          }
 
        }
 
        return nil;
 
      }];
 
    }];
 
  }];
 
  // Add block in queue
 
    [[AppDelegate sharedAppDelegate].queue addOperation:imageblock];
```


[Here](https://www.logisticinfotech.com/blog/react-native-upload-multiple-images-queue) you will find detailed description about this project. Hope this will help lots to person who are dealing with number of images.

