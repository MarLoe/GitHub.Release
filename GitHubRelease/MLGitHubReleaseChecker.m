//
//  GitHubReleaseChecker.m
//  GitHub.Release
//
//  Created by Martin Løbger on 04/03/2018.
//  Copyright © 2018 ML-Consulting. All rights reserved.
//

#import "MLGitHubReleaseChecker.h"

@interface MLGitHubReleaseChecker (NSURLSessionDelegate) <NSURLSessionDelegate>
@end

@implementation MLGitHubReleaseChecker

- (instancetype)initWithUser:(NSString*)user andProject:(NSString*)project
{
    if (self = [super init]) {
        _user = user;
        _project = project;
        _url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/releases", user, project]];
    }
    
    return self;
}


- (void)checkReleaseWithName:(NSString*)releaseName
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", releaseName];
    [self checkReleaseWithPredicate:predicate];
}


- (void)checkReleaseWithPredicate:(NSPredicate*)predicate
{
    _currentRelease = nil;
    _availableRelease = nil;
    _releases = nil;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request addValue:@"application/vnd.github.v3+json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"GET"];
    
    __weak MLGitHubReleaseChecker *weakSelf = self;
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [weakSelf handleReposnseForPredicate:predicate data:data response:response error:error];
    }];
    
    [postDataTask resume];
}


- (void)handleReposnseForPredicate:(NSPredicate*)predicate data:(NSData*)data response:(NSURLResponse*)response error:(NSError*)error
{
    __weak MLGitHubReleaseChecker *weakSelf = self;
    if (error != nil) {
        NSLog(@"%@", error);
        if ([_delegate respondsToSelector:@selector(gitHubReleaseChecker:failedWithError:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.delegate gitHubReleaseChecker:self failedWithError:error];
            });
        }
        return;
    }
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        if (httpResponse.statusCode != 200) {
            error = [NSError errorWithDomain:NSURLErrorDomain code:httpResponse.statusCode userInfo:nil];
            NSLog(@"%@", error);
            if ([_delegate respondsToSelector:@selector(gitHubReleaseChecker:failedWithError:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.delegate gitHubReleaseChecker:self failedWithError:error];
                });
            }
            return;
        }
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"publishedAt" ascending:NO];
    MLGitHubReleases* releasesArray = [MLGitHubReleaseFromData(data, &error) sortedArrayUsingDescriptors:@[sortDescriptor]];
    if (error != nil) {
        if ([_delegate respondsToSelector:@selector(gitHubReleaseChecker:failedWithError:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.delegate gitHubReleaseChecker:self failedWithError:error];
            });
        }
        return;
    }
    
    _currentRelease = [releasesArray filteredArrayUsingPredicate:predicate].firstObject;
    if (_currentRelease == nil) {
        if ([_delegate respondsToSelector:@selector(gitHubReleaseChecker:failedWithError:)]) {
            NSString* localizedDescription = [NSString stringWithFormat:NSLocalizedString(@"Release was not found using predicate: %@", -), predicate];
            error = [NSError errorWithDomain:GitHubReleaseCheckerErrorDomain code:GitHubReleaseCheckerErrorNotFound userInfo:@{ NSLocalizedDescriptionKey : localizedDescription }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.delegate gitHubReleaseChecker:self failedWithError:error];
            });
        }
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(gitHubReleaseChecker:foundReleaseInfo:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.delegate gitHubReleaseChecker:self foundReleaseInfo:weakSelf.currentRelease];
        });
    }
    
    if (!_includeDraft) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isDraft == %i", 0];
        releasesArray = [releasesArray filteredArrayUsingPredicate:predicate];
    }
    
    if (!_includePrerelease) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isPrerelease == %i", 0];
        releasesArray = [releasesArray filteredArrayUsingPredicate:predicate];
    }
    
    _releases = releasesArray;
    
    _availableRelease = _releases.firstObject;
    if (_availableRelease != _currentRelease) {
        // New release available
        if ([_delegate respondsToSelector:@selector(gitHubReleaseChecker:foundNewReleaseInfo:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.delegate gitHubReleaseChecker:self foundNewReleaseInfo:weakSelf.availableRelease];
            });
        }
    }
    
}


- (NSString*)generateReleaseNoteFromRelease:(MLGitHubRelease*)fromRelease toRelease:(MLGitHubRelease*)toRelease
{
    return [[self generateReleaseNoteFromRelease:fromRelease
                                       toRelease:toRelease
                            withHeaderAttributes:nil andBodyAttributes:nil] string];
}

- (NSAttributedString*)generateReleaseNoteFromRelease:(MLGitHubRelease*)fromRelease toRelease:(MLGitHubRelease*)toRelease withHeaderAttributes:(NSDictionary<NSAttributedStringKey, id>*)headerAttributes andBodyAttributes:(NSDictionary<NSAttributedStringKey, id>*)bodyAttributes;
{
    NSUInteger fromIndex = [_releases indexOfObject:fromRelease];
    if (fromIndex == NSNotFound) {
        NSLog(@"ERROR: Release not found %@", fromRelease);
        return nil;
    }
    
    NSUInteger toIndex = [_releases indexOfObject:toRelease];
    if (toIndex == NSNotFound) {
        NSLog(@"ERROR: Release not found %@", toRelease);
        return nil;
    }
    
    NSEnumerationOptions enumOptions = NSEnumerationConcurrent;
    if (fromIndex < toIndex) {
        NSUInteger tmp = fromIndex;
        fromIndex = toIndex;
        toIndex = tmp;
        enumOptions |= NSEnumerationReverse;
    }
    
    
    NSMutableAttributedString* result = [[NSMutableAttributedString alloc] init];
    NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(toIndex, fromIndex - toIndex)];
    
    [result beginEditing];
    NSAttributedString* newLine = [[NSAttributedString alloc] initWithString:@"\n"];
    [_releases enumerateObjectsAtIndexes:indexSet options:enumOptions usingBlock:^(MLGitHubRelease * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (result.length > 0) {
            [result appendAttributedString:newLine];
            [result appendAttributedString:newLine];
        }
        
        [result appendAttributedString:[[NSAttributedString alloc] initWithString:obj.name attributes:headerAttributes]];
        [result appendAttributedString:newLine];
        
        [result appendAttributedString:[[NSAttributedString alloc] initWithString:obj.body attributes:bodyAttributes]];
    }];
    [result endEditing];
    
    return [result copy];
}


@end
