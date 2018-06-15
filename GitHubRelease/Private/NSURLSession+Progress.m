//
//  NSURLSession+Progress.m
//  GitHubRelease
//
//  Created by GN Hearing on 14/06/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import "NSURLSession+Progress.h"
#import <objc/runtime.h>

static char* kProgressHandlerKey    = "kProgressHandlerKey";
static char* kCompletionHandlerKey  = "kCompletionHandlerKey";
static char* kProgressKey           = "kProgressKey";

@implementation NSURLSession (Progress)

@dynamic progressHandler;
@dynamic completionHandler;
@dynamic progress;

- (void)setProgressHandler:(MLGitHubAssetProgressHandler)handler
{
    objc_setAssociatedObject(self, kProgressHandlerKey, handler, OBJC_ASSOCIATION_RETAIN);
}

- (MLGitHubAssetProgressHandler)progressHandler
{
    return objc_getAssociatedObject(self, kProgressHandlerKey);
}

- (void)setCompletionHandler:(MLGitHubAssetCompletionHandler)handler
{
    objc_setAssociatedObject(self, kCompletionHandlerKey, handler, OBJC_ASSOCIATION_RETAIN);
}

- (MLGitHubAssetCompletionHandler)completionHandler
{
    return objc_getAssociatedObject(self, kCompletionHandlerKey);
}

- (void)setProgress:(NSProgress*)progress
{
    objc_setAssociatedObject(self, kProgressKey, progress, OBJC_ASSOCIATION_RETAIN);
}

- (NSProgress*)progress
{
    return objc_getAssociatedObject(self, kProgressKey);
}



@end
