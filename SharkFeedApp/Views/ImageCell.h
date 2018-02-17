//
//  ImageCell.h
//  SharkFeedApp
//
//  Created by Jimit Shah on 2/17/18.
//  Copyright © 2018 Jimit Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Image;

@interface ImageCell : UICollectionViewCell
-(void)updateUI:(nonnull Image*)Image;
  @end
