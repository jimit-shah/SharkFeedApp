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
  
}

- (IBAction)openTapped:(UIButton *)sender {
  
}

-(void)updateUI:(nonnull Image*)Image {
     
     UIImage *sharkImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Image.imageLURL]]];
     self.sharkImageView.image = sharkImage;
    self.titleTextView.text = Image.title;
   }
   


@end
