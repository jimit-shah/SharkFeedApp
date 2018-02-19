//
//  LightBoxViewController.m
//  SharkFeedApp
//
//  Created by Jimit Shah on 2/18/18.
//  Copyright © 2018 Jimit Shah. All rights reserved.
//

#import "LightBoxViewController.h"
#import "Image.h"

@interface LightBoxViewController()
@property (weak, nonatomic) IBOutlet UIImageView *sharkImageView;
@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (assign) BOOL isFullScreen;
@property (weak, nonatomic) UIImage *lImage;
@property (weak, nonatomic) NSString *lURL;
//@property (weak, nonatomic) UIImage *oImage;

@end

@implementation LightBoxViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.isFullScreen = YES;
  [self updateUI: self.imageData];
  self.navigationController.navigationBar.translucent = YES;
  [self.navigationController setNavigationBarHidden:YES];
  //self.navigationController.view.backgroundColor = [UIColor clearColor];
}
- (IBAction)toggleButtonTouched:(id)sender {
  if (self.isFullScreen) {
    [self.navigationController setNavigationBarHidden:self.isFullScreen];
    self.isFullScreen = NO;
  } else {
    [self.navigationController setNavigationBarHidden:self.isFullScreen];
    self.isFullScreen = YES;
  }
}

- (IBAction)downloadTapped:(UIButton *)sender {
  
  
  UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.lImage] applicationActivities:nil];
  
  NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                 UIActivityTypePrint,
                                 UIActivityTypeAssignToContact,
                                 UIActivityTypeAddToReadingList,
                                 UIActivityTypePostToFlickr,
                                 UIActivityTypePostToVimeo];

  activityVC.excludedActivityTypes = excludeActivities;

  [self presentViewController:activityVC animated:YES completion: nil];
  
}

- (IBAction)openTapped:(UIButton *)sender {
  
  NSURL *url = [NSURL URLWithString:self.lURL];
  [UIApplication.sharedApplication openURL:url options:@{} completionHandler:^(BOOL success) {
    if(success) {
      NSLog(@"Opended url");
    }
  }];
 
  
}

-(void)updateUI:(nonnull Image*)Image {
  self.lURL = Image.imageLURL;
  UIImage *sharkImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Image.imageLURL]]];
  self.sharkImageView.image = sharkImage;
  self.titleTextView.text = Image.title;
  self.lImage = sharkImage;
}



@end
