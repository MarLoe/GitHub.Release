//
//  ViewController.h
//  Test.macOS
//
//  Created by Martin Løbger on 12/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GitHubRelease.h"

@interface ViewController : NSViewController <GitHubReleaseCheckerDelegate>

@property (nonatomic, readonly) NSString* version;
@property (nonatomic, strong) GitHubReleaseChecker* releaseChecker;

@end

