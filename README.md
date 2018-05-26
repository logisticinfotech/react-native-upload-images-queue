File upload is an essential aspect of any project. Given this importance, it is surprising that many developers face challenges of adding file upload feature to their projects, specially while they have to deal with number of images and project is mostly related to images.

In real world you may require to upload number of images either dropbox, google drive or other storage service providers. As a developer you may also face challenges to upload number of photos concurrently but many developers are not aware of how to use queue for uploading multiple images in background and without downgrading app performance, specially for memory related issues if they upload all images in single call.

Here I have created native iOS module with my React Native code because of react-native-photo framework not allowing me to fetch resized image directly so I have to accomplish that using native code here you will get all detail about this process(blog demo). Generally we are using mostly using S3 bucket for file uploading so I have used that you may use your own server too as per your requirements.

Actually S3 bucket allow single image upload in single call but I have number of images to upload to S3. To accomplish this I have used queue feature of native which will simplify uploading process in background without holding much more memory of device.

Here you will find code of whole demo project with React Native. Hope this will help lots to person who are dealing with number of images.