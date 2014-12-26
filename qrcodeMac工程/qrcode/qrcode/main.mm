//
//  main.m
//  qrcode
//
//  Created by trojan on 14/12/8.
//  Copyright (c) 2014年 willonboy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/CIFilter.h>
#import "DataMatrix.h"
#import "QREncoder.h"
#import <AppKit/AppKit.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        if (argc < 3)
        {
            NSLog(@"参数小于3");
            return 1;
        }
        
            //the qrcode is square. now we make it 250 pixels wide
        int qrcodeImageDimension = 300;
        
        NSString *txtStr = [NSString stringWithUTF8String:argv[1]];
        NSString *filePathStr = [NSString stringWithUTF8String:argv[2]];
            //first encode the string into a matrix of bools, TRUE for black dot and FALSE for white. Let the encoder decide the error correction level and version
        DataMatrix *qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:txtStr];
            //then render the matrix
        CGImageRef qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:qrcodeImageDimension];
        if (!qrcodeImage)
        {
            NSLog(@"make qrcode matrix failed");
            return 1;
        }
        
        NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
            // Get the image dimensions.
        imageRect.size.height = CGImageGetHeight(qrcodeImage);
        imageRect.size.width = CGImageGetWidth(qrcodeImage);
        
            // Create a new image to receive the Quartz image data.
        NSImage *newImage = [[NSImage alloc] initWithSize:imageRect.size];
        [newImage lockFocus];
            // Get the Quartz context and draw.
        CGContextRef imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
        CGContextDrawImage(imageContext, *(CGRect*)&imageRect, qrcodeImage);
        [newImage unlockFocus];
        
        BOOL isSuccess = [newImage.TIFFRepresentation writeToFile:filePathStr atomically:YES];
        NSLog(@"make qrcode image file %@", isSuccess ? @"success" : @"failed");
        if (isSuccess)
        {
            return 1;
        }
    }
    return 0;
}
