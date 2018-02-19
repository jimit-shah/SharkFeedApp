//
//  ImageCell.m
//  SharkFeedApp
//
//  Created by Jimit Shah on 2/17/18.
//  Copyright © 2018 Jimit Shah. All rights reserved.
//

#import "ImageCell.h"
#import "Image.h"
@interface ImageCell()
//  @property (weak, nonatomic) IBOutlet UIView *cellView;
  @property (weak, nonatomic) IBOutlet UIImageView *sharkImageView;
@end

@implementation ImageCell
  
- (void)awakeFromNib {
  [super awakeFromNib];

  self.layer.cornerRadius = 2.0;
  self.layer.shadowColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:0.8].CGColor;
  self.layer.shadowOpacity = 0.8;
  self.layer.shadowRadius = 5.0;
  self.layer.shadowOffset = CGSizeMake(0.0,2.0);
}
  
-(void)updateUI:(nonnull Image*)Image {
  
  UIImage *sharkImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Image.imageURL]]];
  self.sharkImageView.image = sharkImage;
}

@end
