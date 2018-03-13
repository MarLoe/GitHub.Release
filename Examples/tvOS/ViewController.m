//
//  ViewController.m
//  Example.tvOS
//
//  Created by Martin Løbger on 13/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    NSBundle* prefPaneBundle = [NSBundle bundleForClass:self.class];
    _version = [prefPaneBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    // Try setting _version to something old
    //_version = @"0.1.0";
    
    
    // Do any additional setup after loading the view.
    self.releaseChecker = [[MLGitHubReleaseChecker alloc] initWithUser:@"MarLoe" andProject:@"GitHub.Release"];
    _releaseChecker.delegate = self;
    [_releaseChecker checkRelease:_version];
}


#pragma mark - GitHubReleaseCheckerDelegate

- (void)gitHubReleaseChecker:(MLGitHubReleaseChecker*)sender checkRelease:(NSString*)releaseName foundReleaseInfo:(MLGitHubRelease*)releaseInfo
{
    NSLog(@"%@: %@", releaseName, releaseInfo);
}


- (void)gitHubReleaseChecker:(MLGitHubReleaseChecker*)sender checkRelease:(NSString*)releaseName foundNewReleaseInfo:(MLGitHubRelease*)releaseInfo
{
    NSString* repoUrl = releaseInfo.htmlURL;
    if (repoUrl.length == 0) {
        return;
    }
    
    NSString* message = [NSString stringWithFormat:NSLocalizedString(@"Version %@ is available. You are currently running %@", -),
                         releaseInfo.name,
                         releaseName
                         ];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Update Available"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"View" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // TODO: tvOS does not support opening a webpage
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)gitHubReleaseChecker:(MLGitHubReleaseChecker *)sender checkRelease:(NSString *)releaseName failedWithError:(NSError *)error
{
    NSLog(@"%@: %@", releaseName, error);
}

@end


