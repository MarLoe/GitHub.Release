//
//  ViewController.m
//  Example.tvOS
//
//  Created by Martin Løbger on 13/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak) IBOutlet UIImageView*  imageView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    NSBundle* prefPaneBundle = [NSBundle bundleForClass:self.class];
    _version = [prefPaneBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    // Try setting _version to something old
    _version = @"0.1.0";
    
    
    // Do any additional setup after loading the view.
    self.releaseChecker = [[MLGitHubReleaseChecker alloc] initWithUser:@"MarLoe" andProject:@"GitHub.Release"];
    _releaseChecker.delegate = self;
    [_releaseChecker checkReleaseWithName:_version];
}


#pragma mark - GitHubReleaseCheckerDelegate

- (void)gitHubReleaseChecker:(MLGitHubReleaseChecker*)sender foundReleaseInfo:(MLGitHubRelease*)releaseInfo
{
    NSLog(@"%@", releaseInfo);
}


- (void)gitHubReleaseChecker:(MLGitHubReleaseChecker*)sender foundNewReleaseInfo:(MLGitHubRelease*)releaseInfo
{
    if (releaseInfo.htmlURL == nil) {
        return;
    }
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name == %@", @"Asset.png"];
    MLGitHubAsset* asset = [releaseInfo.assets filteredArrayUsingPredicate:predicate].firstObject;
    
    NSString* message = [NSString stringWithFormat:NSLocalizedString(@"Version %@ is available. You are currently running %@", -),
                         releaseInfo.name,
                         sender.currentRelease.name
                         ];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Update Available"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"View" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action) {
        // TODO: tvOS does not support opening a webpage
    }]];
    if (asset != nil) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Download" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action) {
            [asset downloadWithProgressHandler:^(NSURLResponse* _Nullable response, NSProgress* _Nullable progress) {
                
            } andCompletionHandler:^(NSURLResponse* _Nullable response, NSProgress* _Nullable progress, NSURL* _Nullable location, NSError* _Nullable error) {
                // TODO: Handle asset and do what needs to be done
                NSLog(@"%@", error ?: location);
                
                // The "location" file must be handled before exiting this block.
                // Once exited, the file will be deleted.
                UIImage* image = [UIImage imageWithContentsOfFile:location.path];
                [self.imageView performSelectorOnMainThread:@selector(setImage:)
                                                 withObject:image
                                              waitUntilDone:YES]; // <- We will wait as the image might be lazy loaded and then the "location" is gone
            }];
        }]];
    }
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)gitHubReleaseChecker:(MLGitHubReleaseChecker*)sender failedWithError:(NSError*)error
{
    NSLog(@"%@", error);
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:error.localizedDescription
                                                                   message:error.localizedRecoverySuggestion
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end


