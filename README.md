File upload is an essential aspect of any project. Given this importance, it is surprising that many developers face challenges of adding file upload feature to their projects, specially while they have to deal with multiple image upload and project is mostly related to images.

Specifically for mobile application we need to take care of memory being used by application and while we have number of images being uploaded from mobile application.

Here I have created native iOS module with my React Native code because of react-native-photo framework not allowing me to fetch resized image directly so I have to accomplish that using native code here you will get all detail about [this blog](https://www.logisticinfotech.com/blog/react-native-import-resized-image-photo-gallery). Generally we are using mostly using S3 bucket for file uploading so I have used that you may use your own server too as per your requirements.

Actually S3 bucket allow single image upload in single call but I have number of images to upload to S3. To accomplish this I have used queue feature of native which will simplify uploading process in background without holding much more memory of device.

[Here](https://www.logisticinfotech.com/blog/react-native-upload-multiple-images-queue) you will find detailed description about this project. Hope this will help lots to person who are dealing with number of images.

