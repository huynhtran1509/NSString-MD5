//
//  NSString+MD5.m
//  txmanios
//
//  Created by 晓童 韩 on 16/1/25.
//  Copyright © 2016年 up366. All rights reserved.
//

#import "NSString+MD5.h"
// Standard library
#include <stdint.h>
#include <stdio.h>

// Core Foundation
#include <CoreFoundation/CoreFoundation.h>

// Cryptography
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)

- (NSString *)MD5 {
    // Create pointer to the string as UTF8
    const char *ptr = [self UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 bytes MD5 hash value, store in buffer
    CC_MD5(ptr, (uint) strlen(ptr), md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", md5Buffer[i]];
    
    return output;
}

+ (NSString *)MD5WithInput:(NSString *)input {
    return [input MD5];
}

+ (NSString *)MD5WithFilePath:(NSString *)filePath
{
    // 获取文件大小
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        NSLog(@"不存在指定的文件信息，所以无法进行文件MD5计算:%@", filePath);
        return nil;
    }
    NSError *error = nil;
    NSNumber *fileSize = nil;
    NSDictionary *fileDict = [fileManager attributesOfItemAtPath:filePath error:&error];
    if (!error && fileDict) {
        fileSize = [NSNumber numberWithUnsignedLongLong:[fileDict fileSize]];
    }
    
    if (!fileSize) {
        NSLog(@"未能成功计算文件大小信息，无法进行文件MD5计算:%@", filePath);
        return nil;
    }
    unsigned long long fileSizeLong = fileSize.unsignedLongLongValue;
    
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)filePath, FileHashDefaultChunkSizeForReadingData,
                                                                   fileSizeLong < fileMD5noLimitSize ? 0 : (fileSizeLong < fileMD5Per256LimitSize ? fileMD5256Limit : (fileSizeLong < fileMD5Per512LimitSize ? fileMD5512Limit : fileMD51024Limit)));
}


//---------------------------------------------------------
// Function definition
//---------------------------------------------------------

CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,
                                      size_t chunkSizeForReadingData, size_t limitSize) {
    
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) return nil;
    
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) return nil;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) return nil;
    
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        
        size_t realReadSize = chunkSizeForReadingData;
        
        uint8_t buffer[realReadSize];
        CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                  (UInt8 *)buffer,
                                                  (CFIndex)sizeof(buffer));
        
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        
        CC_MD5_Update(&hashObject,
                      (const void *)buffer,
                      (CC_LONG)readBytesCount);
        
        // skip...
        if (limitSize > 0) {
            uint8_t skipBuffer[limitSize];
            CFReadStreamRead(readStream, (UInt8 *)skipBuffer, (CFIndex)sizeof(skipBuffer));
        }
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) return nil;
    
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,
                                       (const char *)hash,
                                       kCFStringEncodingUTF8);
    
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}
@end
