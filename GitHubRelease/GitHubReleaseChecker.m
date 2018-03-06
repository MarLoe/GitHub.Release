//
//  GitHubReleaseChecker.m
//  VMware
//
//  Created by Martin Løbger on 04/03/2018.
//  Copyright © 2018 ML-Consulting. All rights reserved.
//

#import "GitHubReleaseChecker.h"


NSString* const kGitHubReleaseCheckerNameKey                = @"name";
NSString* const kGitHubReleaseCheckerAssetsKey              = @"assets";


NSErrorDomain const GitHubReleaseCheckerErrorDomain         = @"GitHubReleaseCheckerErrorDomain";

@interface GitHubReleaseChecker (NSURLSessionDelegate) <NSURLSessionDelegate>
@end

// curl -i https://api.github.com/repos/MarLoe/VMware.PreferencePane/releases

@implementation GitHubReleaseChecker

- (instancetype)initWithUser:(NSString*)user andProject:(NSString*)project
{
    if (self = [super init]) {
        _user = user;
        _project = project;
        _url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/releases", user, project]];
    }
    
    return self;
}


- (void)checkRelease:(NSString*)releaseName
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    //[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/vnd.github.v3+json" forHTTPHeaderField:@"Accept"];

    [request setHTTPMethod:@"GET"];

//    [request setHTTPMethod:@"POST"];
//
//
//    NSDictionary *mapData = [[NSDictionary alloc] initWithObjectsAndKeys: @"Value", @"Key",   nil];
//
//    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
//
//    [request setHTTPBody:postData];
    
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error != nil) {
            NSLog(@"%@", error);
            if ([_delegate respondsToSelector:@selector(gitHubReleaseChecker:checkRelease:failedWithError:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate gitHubReleaseChecker:self checkRelease:releaseName failedWithError:error];
                });
            }
            return;
        }
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            if (httpResponse.statusCode != 200) {
                error = [NSError errorWithDomain:NSURLErrorDomain code:httpResponse.statusCode userInfo:nil];
                NSLog(@"%@", error);
                if ([_delegate respondsToSelector:@selector(gitHubReleaseChecker:checkRelease:failedWithError:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_delegate gitHubReleaseChecker:self checkRelease:releaseName failedWithError:error];
                    });
                }
                return;
            }
        }
        
        NSArray* releasesArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error != nil) {
            if ([_delegate respondsToSelector:@selector(gitHubReleaseChecker:checkRelease:failedWithError:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate gitHubReleaseChecker:self checkRelease:releaseName failedWithError:error];
                });
            }
            return;
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", releaseName];
        _currentRelease = [[releasesArray filteredArrayUsingPredicate:predicate] firstObject];
        if (_currentRelease == nil) {
            if ([_delegate respondsToSelector:@selector(gitHubReleaseChecker:checkRelease:failedWithError:)]) {
                NSString* localizedDescription = [NSString stringWithFormat:NSLocalizedString(@"Release with name '%@' was not found", -), releaseName];
                error = [NSError errorWithDomain:GitHubReleaseCheckerErrorDomain code:GitHubReleaseCheckerErrorNotFound userInfo:@{ NSLocalizedDescriptionKey : localizedDescription }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate gitHubReleaseChecker:self checkRelease:releaseName failedWithError:error];
                });
            }
            return;
        }

        if ([_delegate respondsToSelector:@selector(gitHubReleaseChecker:checkRelease:foundReleaseInfo:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate gitHubReleaseChecker:self checkRelease:releaseName foundReleaseInfo:_currentRelease];
            });
        }
        
        if (!_includeDraft) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"draft == %i", 0];
            releasesArray = [releasesArray filteredArrayUsingPredicate:predicate];
        }

        if (!_includePrerelease) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"prerelease == %i", 0];
            releasesArray = [releasesArray filteredArrayUsingPredicate:predicate];
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"published_at" ascending:NO];
        releasesArray = [releasesArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        _availableRelease = releasesArray.firstObject;
        if (_availableRelease != _currentRelease) {
            // New release available
            if ([_delegate respondsToSelector:@selector(gitHubReleaseChecker:checkRelease:foundNewReleaseInfo:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate gitHubReleaseChecker:self checkRelease:releaseName foundNewReleaseInfo:_availableRelease];
                });
            }
        }

    }];
    
    [postDataTask resume];
}

@end
