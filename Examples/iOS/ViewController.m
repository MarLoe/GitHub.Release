//
//  ViewController.m
//  Example.iOS
//
//  Created by Martin Løbger on 12/03/2018.
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
    self.releaseChecker = [[GitHubReleaseChecker alloc] initWithUser:@"MarLoe" andProject:@"GitHub.Release"];
    _releaseChecker.delegate = self;
    [_releaseChecker checkRelease:_version];
}


#pragma mark - GitHubReleaseCheckerDelegate

- (void)gitHubReleaseChecker:(GitHubReleaseChecker*)sender checkRelease:(NSString*)releaseName foundReleaseInfo:(NSDictionary*)releaseInfo
{
    NSLog(@"%@: %@", releaseName, releaseInfo);
}


- (void)gitHubReleaseChecker:(GitHubReleaseChecker*)sender checkRelease:(NSString*)releaseName foundNewReleaseInfo:(NSDictionary*)releaseInfo
{
    NSString* repoUrl = releaseInfo[kGitHubReleaseCheckerHtmlUrlKey];
    if (repoUrl.length == 0) {
        return;
    }
    
    NSString* message = [NSString stringWithFormat:NSLocalizedString(@"Version %@ is available. You are currently running %@", -),
                         releaseInfo[kGitHubReleaseCheckerNameKey],
                         releaseName
                         ];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Update Available"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"View" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:repoUrl] options:@{} completionHandler:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)gitHubReleaseChecker:(GitHubReleaseChecker *)sender checkRelease:(NSString *)releaseName failedWithError:(NSError *)error
{
    NSLog(@"%@: %@", releaseName, error);
}

@end

