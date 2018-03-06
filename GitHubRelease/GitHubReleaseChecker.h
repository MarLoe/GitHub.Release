//
//  GitHubReleaseChecker.h
//  VMware
//
//  Created by Martin Løbger on 04/03/2018.
//  Copyright © 2018 ML-Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>


FOUNDATION_EXPORT NSString* const kGitHubReleaseCheckerNameKey;
FOUNDATION_EXPORT NSString* const kGitHubReleaseCheckerAssetsKey;


FOUNDATION_EXPORT NSErrorDomain const GitHubReleaseCheckerErrorDomain;

NS_ERROR_ENUM(GitHubReleaseCheckerErrorDomain)
{
    GitHubReleaseCheckerErrorUnknown            =   -1,
    GitHubReleaseCheckerErrorNotFound           = -404
};


@class GitHubReleaseChecker;


@protocol GitHubReleaseCheckerDelegate <NSObject>

- (void)gitHubReleaseChecker:(GitHubReleaseChecker*)sender checkRelease:(NSString*)releaseName foundReleaseInfo:(NSDictionary*)releaseInfo;

- (void)gitHubReleaseChecker:(GitHubReleaseChecker*)sender checkRelease:(NSString*)releaseName foundNewReleaseInfo:(NSDictionary*)releaseInfo;

- (void)gitHubReleaseChecker:(GitHubReleaseChecker*)sender checkRelease:(NSString*)releaseName failedWithError:(NSError*)error;

@end


@interface GitHubReleaseChecker : NSObject

@property (nonatomic, readonly) NSURL* url;
@property (nonatomic, readonly) NSString* user;
@property (nonatomic, readonly) NSString* project;

@property (nonatomic, readonly) NSDictionary* currentRelease;
@property (nonatomic, readonly) NSDictionary* availableRelease;

@property (nonatomic, assign) BOOL includeDraft;
@property (nonatomic, assign) BOOL includePrerelease;

@property (nonatomic, weak) id<GitHubReleaseCheckerDelegate> delegate;

- (instancetype)initWithUser:(NSString*)user andProject:(NSString*)project;

- (void)checkRelease:(NSString*)releaseName;

@end
