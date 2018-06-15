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
#import "NSURLSession+Progress.h"

@interface MLGitHubAsset (NSURLSessionDelegate) <NSURLSessionDownloadDelegate, NSURLSessionDataDelegate>
@end


@implementation MLGitHubAsset

- (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        properties = [super propertiesWithDictionary:@{
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
                                                       }];
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

- (void)downloadWithProgressHandler:(MLGitHubAssetProgressHandler)progressHandler andCompletionHandler:(MLGitHubAssetCompletionHandler)completionHandler
//- (void)downloadWithCompletionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler
{
//    _browserDownloadURL = [NSURL URLWithString:@"http://lobger.com/download/ja-energibyg.zip"];

    NSString* backgroundIdentifier = [NSString stringWithFormat:@"com.lobger.github.release.%@", self.nodeId ?: self.name];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:backgroundIdentifier];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:self
                                                     delegateQueue:nil];
    [session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {

        NSPredicate* predicateSuspended = [NSPredicate predicateWithFormat:@"state == %ul", NSURLSessionTaskStateSuspended];
        [[dataTasks filteredArrayUsingPredicate:predicateSuspended] enumerateObjectsUsingBlock:^(NSURLSessionDataTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task resume];
        }];
        [[downloadTasks filteredArrayUsingPredicate:predicateSuspended] enumerateObjectsUsingBlock:^(NSURLSessionDownloadTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task resume];
        }];

        NSPredicate* predicateRunning = [NSPredicate predicateWithFormat:@"state == %ul", NSURLSessionTaskStateRunning];
        if ([dataTasks filteredArrayUsingPredicate:predicateRunning].count > 0 || [downloadTasks filteredArrayUsingPredicate:predicateRunning].count > 0) {
            return;
        }

        session.progressHandler = progressHandler;
        session.completionHandler = completionHandler;

        // Start out as data task - we will convert it to a download task when we get the response.
        NSURLSessionDataTask* task = [session dataTaskWithURL:self.browserDownloadURL];

        if (@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)) {
            // use iOS 11-only feature
            session.progress = task.progress;
            session.progress.totalUnitCount = self.size;
        }
        else {
            session.progress = [NSProgress progressWithTotalUnitCount:self.size];
        }

        [task resume];
    }];
}


- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ - %@", [super description], _name];
}


#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)task
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    session.progress.completedUnitCount = totalBytesWritten;
    session.progress.totalUnitCount = totalBytesExpectedToWrite;

    MLGitHubAssetProgressHandler progressHandler = session.progressHandler;
    if (progressHandler != nil) {
        session.progressHandler(task.response, session.progress);
    }
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)task didFinishDownloadingToURL:(NSURL *)location
{
    MLGitHubAssetCompletionHandler completionHandler = session.completionHandler;
    if (completionHandler != nil) {
        completionHandler(task.response, session.progress, location, nil);
        session.completionHandler = nil; // <- Avoid completion handler being called again in URLSession:task:didCompleteWithError
    }
}


#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)task
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    session.progress.completedUnitCount = 0;
    if ([response isKindOfClass:NSHTTPURLResponse.class]) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSString* contentLengthHeader = httpResponse.allHeaderFields[@"Content-Length"];
        long long contentLength = contentLengthHeader.longLongValue;
        if (contentLength != 0) {
            session.progress.totalUnitCount = contentLength;
        }
    }

    MLGitHubAssetProgressHandler progressHandler = session.progressHandler;
    if (progressHandler != nil) {
        session.progressHandler(response, session.progress);
    }
    completionHandler(NSURLSessionResponseBecomeDownload);
}


#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    MLGitHubAssetCompletionHandler completionHandler = session.completionHandler;
    if (completionHandler != nil) {
        completionHandler(task.response, session.progress, nil, error);
        session.completionHandler = nil;
    }
}

@end
