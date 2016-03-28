//
//  GIFDownloader.m
//  TheJoysOfCode
//
//  Created by Bob on 29/10/12.
//  Copyright (c) 2012 Tall Developments. All rights reserved.
//

#import "GIFDownloader.h"

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define FPS 30

NSString * const kGIF2MP4ConversionErrorDomain = @"GIF2MP4ConversionError";

@implementation GIFDownloader

- (BOOL) processGIFData: (NSData*) data
             toFilePath: (NSURL*) outFilePath
          thumbFilePath: (NSString*) thumbFilePath
              completed: (kGIF2MP4ConversionCompleted) completionHandler {
    
    self.repeatNum = 0;
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    unsigned char *bytes = (unsigned char*)data.bytes;
    NSError* error = nil;
    
    if( !CGImageSourceGetStatus(source) == kCGImageStatusComplete ) {
        error = [NSError errorWithDomain: kGIF2MP4ConversionErrorDomain
                                    code: kGIF2MP4ConversionErrorInvalidGIFImage
                                userInfo: nil];
        CFRelease(source);
        completionHandler(outFilePath.absoluteString, error);
        return NO;
    }
    
    size_t sourceWidth = bytes[6] + (bytes[7]<<8), sourceHeight = bytes[8] + (bytes[9]<<8);
    //size_t sourceFrameCount = CGImageSourceGetCount(source);
    __block size_t currentFrameNumber = 0;
    __block Float64 totalFrameDelay = 0.f;
    
    self.videoWriter = [[AVAssetWriter alloc] initWithURL: outFilePath
                                                           fileType: AVFileTypeQuickTimeMovie
                                                              error: &error];
    if( error ) {
        CFRelease(source);
        completionHandler(outFilePath.absoluteString, error);
        return NO;
    }
    
    /*if( sourceWidth > 640 || sourceWidth == 0) {
        CFRelease(source);
        error = [NSError errorWithDomain: kGIF2MP4ConversionErrorDomain
                                    code: kGIF2MP4ConversionErrorInvalidResolution
                                userInfo: nil];
        completionHandler(outFilePath.absoluteString, error);
        return NO;
    }
    
    if( sourceHeight > 480 || sourceHeight == 0 ) {
        CFRelease(source);
        error = [NSError errorWithDomain: kGIF2MP4ConversionErrorDomain
                                    code: kGIF2MP4ConversionErrorInvalidResolution
                                userInfo: nil];
        completionHandler(outFilePath.absoluteString, error);
        return NO;
    }*/
    
    size_t totalFrameCount = CGImageSourceGetCount(source);
    size_t thumbnailFrameCount = floorf( totalFrameCount * 0.05 );
    
    if( totalFrameCount <= 0 ) {
        CFRelease(source);
        error = [NSError errorWithDomain: kGIF2MP4ConversionErrorDomain
                                    code: kGIF2MP4ConversionErrorInvalidGIFImage
                                userInfo: nil];
        completionHandler(outFilePath.absoluteString, error);
        return NO;
    }
    
    //NSAssert(sourceWidth <= 640, @"%lu is too wide for a video", sourceWidth);
    //NSAssert(sourceHeight <= 480, @"%lu is too tall for a video", sourceHeight);
    
    NSDictionary *videoSettings = @{
    AVVideoCodecKey : AVVideoCodecH264,
    AVVideoWidthKey : @(sourceWidth),
    AVVideoHeightKey : @(sourceHeight)
    };
    
    self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType: AVMediaTypeVideo
                                                                              outputSettings: videoSettings];
    self.videoWriterInput.expectsMediaDataInRealTime = YES;
    
    NSAssert([self.videoWriter canAddInput: self.videoWriterInput], @"Video writer can not add video writer input");
    [self.videoWriter addInput: self.videoWriterInput];
    
    NSDictionary* attributes = @{
    (NSString*)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32ARGB),
    (NSString*)kCVPixelBufferWidthKey : @(sourceWidth),
    (NSString*)kCVPixelBufferHeightKey : @(sourceHeight),
    (NSString*)kCVPixelBufferCGImageCompatibilityKey : @YES,
    (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES
    };
    
    AVAssetWriterInputPixelBufferAdaptor* adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput: self.videoWriterInput
                                                                                                                     sourcePixelBufferAttributes: attributes];
    
    [self.videoWriter startWriting];
    [self.videoWriter startSessionAtSourceTime: CMTimeMakeWithSeconds(totalFrameDelay, FPS)];
    
    while(1) {
        if( self.videoWriterInput.isReadyForMoreMediaData ) {
#if DEBUG
            //NSLog(@"Drawing frame %lu/%lu", currentFrameNumber, totalFrameCount);
#endif
            NSDictionary* options = @{(NSString*)kCGImageSourceTypeIdentifierHint : (id)kUTTypeGIF};
            CGImageRef imgRef = CGImageSourceCreateImageAtIndex(source, currentFrameNumber, (__bridge CFDictionaryRef)options);
            if (!imgRef) {
                if (self.repeatNum < 2) {
                    self.repeatNum++;
                    currentFrameNumber = 0;
                    imgRef = CGImageSourceCreateImageAtIndex(source, currentFrameNumber, (__bridge CFDictionaryRef)options);
                }
            }
            if( imgRef ) {
                CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(source, currentFrameNumber, NULL);
                CFDictionaryRef gifProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
                
                //Save our thumbnail
                if( thumbnailFrameCount == currentFrameNumber ) {
                    if( [[NSFileManager defaultManager] fileExistsAtPath: thumbFilePath] ) {
                        [[NSFileManager defaultManager] removeItemAtPath: thumbFilePath error: nil];
                    }
                    
                    UIImage* img = [UIImage imageWithCGImage: imgRef];
                    [UIImagePNGRepresentation(img) writeToFile: thumbFilePath atomically: YES];
                }
                
                if( gifProperties ) {
                    CVPixelBufferRef pxBuffer = [self newBufferFrom: imgRef
                                                withPixelBufferPool: adaptor.pixelBufferPool
                                                      andAttributes: adaptor.sourcePixelBufferAttributes];
                    if( pxBuffer ) {
                        NSNumber* delayTime = CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime);
                        totalFrameDelay += delayTime.floatValue;
                        CMTime time = CMTimeMakeWithSeconds(totalFrameDelay, FPS);
                        
                        if( ![adaptor appendPixelBuffer: pxBuffer withPresentationTime: time] ) {
                            NSLog(@"Could not save pixel buffer!: %@", self.videoWriter.error);
                            CFRelease(properties);
                            CGImageRelease(imgRef);
                            CVBufferRelease(pxBuffer);
                            break;
                        }
                        
                        CVBufferRelease(pxBuffer);
                    }
                }
                
                if( properties ) CFRelease(properties);
                CGImageRelease(imgRef);
                
                currentFrameNumber++;
            }
            else {
                //was no image returned -> end of file?
                [self.videoWriterInput markAsFinished];
                
                /*void (^videoSaveFinished)(void) = ^{
                    completionHandler(outFilePath.absoluteString, nil);
                };*/
                
                if( [self.videoWriter respondsToSelector: @selector(finishWritingWithCompletionHandler:)]) {
                    [self.videoWriter finishWritingWithCompletionHandler: ^{
                        NSLog(@"%@",self.videoWriter);
                        NSLog(@"Write Ended");
                        completionHandler(outFilePath.absoluteString, nil);
                    }];
                }
        break;
            }
        }
        else {
            //NSLog(@"Was not ready...");
            [NSThread sleepForTimeInterval: 0.1];
        }
    };
    
    CFRelease(source);
    
    return YES;
};

- (CVPixelBufferRef) newBufferFrom: (CGImageRef) frame
               withPixelBufferPool: (CVPixelBufferPoolRef) pixelBufferPool
                     andAttributes: (NSDictionary*) attributes {
    NSParameterAssert(frame);
    
    size_t width = CGImageGetWidth(frame);
    size_t height = CGImageGetHeight(frame);
    size_t bpc = 8;
    CGColorSpaceRef colorSpace =  CGColorSpaceCreateDeviceRGB();
    
    CVPixelBufferRef pxBuffer = NULL;
    CVReturn status = kCVReturnSuccess;
    
    if( pixelBufferPool )
        status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &pxBuffer);
    else {
        status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)attributes, &pxBuffer);
    }
    
    NSAssert(status == kCVReturnSuccess, @"Could not create a pixel buffer");
    
    CVPixelBufferLockBaseAddress(pxBuffer, 0);
    void *pxData = CVPixelBufferGetBaseAddress(pxBuffer);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pxBuffer);
    
    
    CGContextRef context = CGBitmapContextCreate(pxData,
                                                 width,
                                                 height,
                                                 bpc,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSAssert(context, @"Could not create a context");
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), frame);
    
    CVPixelBufferUnlockBaseAddress(pxBuffer, 0);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return pxBuffer;
}

@end
