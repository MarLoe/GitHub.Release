//
//  ViewController.h
//  Example.iOS
//
//  Created by Martin Løbger on 12/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GitHubRelease.h"

@interface ViewController : UIViewController <MLGitHubReleaseCheckerDelegate>

@property (nonatomic, readonly) NSString* version;
@property (nonatomic, strong) MLGitHubReleaseChecker* releaseChecker;

@end

