//
//  GitHubReleaseChecker.h
//  VMware
//
//  Created by Martin Løbger on 04/03/2018.
//  Copyright © 2018 ML-Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>


FOUNDATION_EXPORT NSErrorDomain const GitHubReleaseCheckerErrorDomain;

NS_ERROR_ENUM(GitHubReleaseCheckerErrorDomain)
{
    GitHubReleaseCheckerErrorUnknown            =   -1,
    GitHubReleaseCheckerErrorNotFound           = -404,
};


@class MLGitHubRelease;
@class MLGitHubReleaseChecker;


@protocol GitHubReleaseCheckerDelegate <NSObject>

- (void)gitHubReleaseChecker:(MLGitHubReleaseChecker*)sender foundReleaseInfo:(MLGitHubRelease*)releaseInfo;

- (void)gitHubReleaseChecker:(MLGitHubReleaseChecker*)sender foundNewReleaseInfo:(MLGitHubRelease*)releaseInfo;

- (void)gitHubReleaseChecker:(MLGitHubReleaseChecker*)sender failedWithError:(NSError*)error;

@end


@interface MLGitHubReleaseChecker : NSObject

@property (nonatomic, readonly) NSURL* url;
@property (nonatomic, readonly) NSString* user;
@property (nonatomic, readonly) NSString* project;

@property (nonatomic, readonly) MLGitHubRelease* currentRelease;
@property (nonatomic, readonly) MLGitHubRelease* availableRelease;

@property (nonatomic, assign) BOOL includeDraft;
@property (nonatomic, assign) BOOL includePrerelease;

@property (nonatomic, weak) id<GitHubReleaseCheckerDelegate> delegate;

- (instancetype)initWithUser:(NSString*)user andProject:(NSString*)project;

- (void)checkReleaseWithName:(NSString*)releaseName;
- (void)checkReleaseWithPredicate:(NSPredicate*)predicate;

- (void)downloadAssetNamed:(NSString*)assetName;

@end
