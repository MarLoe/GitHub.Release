//
//  MLGitHubUploader.h
//  GitHubRelease
//
//  Created by Martin Løbger on 18/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLGitHubObject.h"


@interface MLGitHubUploader : MLGitHubObject

@property (nonatomic, nullable, copy)   NSString*       login;
@property (nonatomic, nullable, strong) NSNumber*       identifier;
@property (nonatomic, nullable, copy)   NSURL*          avatarURL;
@property (nonatomic, nullable, copy)   NSString*       gravatarID;
@property (nonatomic, nullable, copy)   NSURL*          url;
@property (nonatomic, nullable, copy)   NSURL*          htmlURL;
@property (nonatomic, nullable, copy)   NSURL*          followersURL;
@property (nonatomic, nullable, copy)   NSURL*          followingURL;
@property (nonatomic, nullable, copy)   NSURL*          gistsURL;
@property (nonatomic, nullable, copy)   NSURL*          starredURL;
@property (nonatomic, nullable, copy)   NSURL*          subscriptionsURL;
@property (nonatomic, nullable, copy)   NSURL*          organizationsURL;
@property (nonatomic, nullable, copy)   NSURL*          reposURL;
@property (nonatomic, nullable, copy)   NSURL*          eventsURL;
@property (nonatomic, nullable, copy)   NSURL*          receivedEventsURL;
@property (nonatomic, nullable, copy)   NSString*       type;
@property (nonatomic, nullable, strong) NSNumber*       siteAdmin;

@end



