//
//  NSString+MD5.h
//  txmanios
//
//  Created by 晓童 韩 on 16/1/25.
//  Copyright © 2016年 up366. All rights reserved.
//

#import <Foundation/Foundation.h>

// In bytes (256K)
#define FileHashDefaultChunkSizeForReadingData 262144

// 80M以内无分割计算
#define fileMD5noLimitSize      80  * 1024 * 1024
// 256M以内按照256K间隔分割
#define fileMD5Per256LimitSize  256 * 1024 * 1024
// 512M以内按照512K间隔分割
#define fileMD5Per512LimitSize  512 * 1024 * 1024

// 三种不同limit的大小
#define fileMD5256Limit     256  * 1024
#define fileMD5512Limit     512  * 1024
#define fileMD51024Limit    1024 * 1024


// Extern
#if defined(__cplusplus)
#define FILEMD5HASH_EXTERN extern "C"
#else
#define FILEMD5HASH_EXTERN extern
#endif

//---------------------------------------------------------
// Function declaration
//---------------------------------------------------------

FILEMD5HASH_EXTERN CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,
                                                         size_t chunkSizeForReadingData, size_t limitSize);

@interface NSString (MD5)

/**
 *  获取字符串的MD5加密
 *
 *  @return 字符串的MD5加密
 */
- (NSString *)MD5;

/**
 *  获取字符串的MD5加密
 *
 *  @param input
 *
 *  @return 字符串的MD5加密
 */
+ (NSString *)MD5WithInput:(NSString *)input;

/**
 *  获取文件的MD5加密
 *
 *  @param filePath 文件路径
 *
 *  @return 加密
 */
+ (NSString *)MD5WithFilePath:(NSString *)filePath;
@end
