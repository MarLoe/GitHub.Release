//
//  MLGitHibAsset.m
//  GitHubRelease
//
//  Created by Martin Løbger on 29/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import "MLGitHubAsset.h"
#import "MLGitHubUploader.h"
#import "MLGitHubPrivate.h"

@interface MLGitHubAsset (NSURLSessionDelegate) <NSURLSessionDelegate>
@end


@implementation MLGitHubAsset

- (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        properties = @{
                       @"url":                  @"url",
                       @"id":                   @"identifier",
                       @"name":                 @"name",
                       @"label":                @"label",
                       @"uploader":             @"uploader",
                       @"content_type":         @"contentType",
                       @"state":                @"state",
                       @"size":                 @"size",
                       @"download_count":       @"downloadCount",
                       @"created_at":           @"createdAt",
                       @"updated_at":           @"updatedAt",
                       @"browser_download_url": @"browserDownloadURL",
                       };
    });
    return properties;
}


+ (instancetype)fromJSONDictionary:(NSDictionary *)dict error:(NSError **)error
{
    return dict ? [[MLGitHubAsset alloc] initWithJSONDictionary:dict error:error] : nil;
}


- (instancetype)initWithJSONDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)error
{
    if (self = [super initWithJSONDictionary:dict error:error]) {
        @try {
            _uploader = [MLGitHubUploader fromJSONDictionary:(id)_uploader error:error];
        }
        @catch (NSError* e) {
            if (error != nil) {
                *error = e;
            }
            return nil;
        }
    }
    return self;
}

- (void)downloadWithCompletionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_browserDownloadURL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

    [request setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:completionHandler];
    
    [postDataTask resume];
}

@end
