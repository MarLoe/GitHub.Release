//
//  MLGitHubError.h
//  GitHubRelease
//
//  Created by Martin Løbger on 31/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSErrorDomain const GitHubReleaseCheckerErrorDomain;

NS_ERROR_ENUM(GitHubReleaseCheckerErrorDomain)
{
    GitHubReleaseCheckerErrorUnknown            =    -1,
    GitHubReleaseCheckerErrorNotFound           =  -404,
    GitHubReleaseCheckerErrorUnknownProperty    = -1013,
};

