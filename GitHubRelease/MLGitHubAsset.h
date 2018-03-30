//
//  MLGitHibAsset.h
//  GitHubRelease
//
//  Created by Martin Løbger on 29/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MLGitHubUploader;


@interface MLGitHubAsset : NSObject
@property (nonatomic, nullable, copy)   NSString* url;
@property (nonatomic, assign)           NSInteger identifier;
@property (nonatomic, nullable, copy)   NSString* name;
@property (nonatomic, nullable, copy)   NSString* label;
@property (nonatomic, nullable, strong) MLGitHubUploader *uploader;
@property (nonatomic, nullable, copy)   NSString *contentType;
@property (nonatomic, nullable, copy)   NSString *state;
@property (nonatomic, assign)           NSInteger size;
@property (nonatomic, assign)           NSInteger downloadCount;
@property (nonatomic, nullable, copy)   NSString *createdAt;
@property (nonatomic, nullable, copy)   NSString *updatedAt;
@property (nonatomic, nullable, copy)   NSString *browserDownloadURL;
@end

@interface MLGitHubAsset (JSONConversion)
+ (instancetype _Nonnull )fromJSONDictionary:(NSDictionary *_Nullable)dict;
@end

