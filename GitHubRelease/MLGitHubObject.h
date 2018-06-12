//
//  MLGitHubObject.h
//  GitHubRelease
//
//  Created by Martin Løbger on 30/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLGitHubObject : NSObject

@property (nonatomic, nullable, strong) NSNumber*                   identifier;
@property (nonatomic, nullable, copy)   NSString*                   nodeId;
@property (nonatomic, nullable, copy)   NSURL*                      url;

@end
