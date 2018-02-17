//
//  ViewController.m
//  SharkFeedApp
//
//  Created by Jimit Shah on 2/17/18.
//  Copyright © 2018 Jimit Shah. All rights reserved.
//

#import "FeedsViewController.h"
#import "HTTPService.h"
#import "Image.h"
#import "ImageCell.h"

@interface FeedsViewController ()
  
#pragma mark - Properties
  
  @property (strong, nonatomic) NSMutableArray *imageList;
  @property (strong, nonatomic) UIActivityIndicatorView *spinner;
  
#pragma mark - Outlets
  
  @property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
  
  
  @end

@implementation FeedsViewController
  
#pragma mark - Lifecycle
  
- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.collectionView.dataSource = self;
  self.collectionView.delegate = self;
  
  self.spinner = [[UIActivityIndicatorView alloc]init];
  
  if (_imageList == nil) {
    _imageList = [[NSMutableArray alloc]init];
  }
  
  [self getImages];
  
  // reload collection view -- no need as it's part of getImages
  //[self.collectionView reloadData];
  
}
  
#pragma mark - Actions
  
  
  
#pragma mark fetchDogs
  //- (IBAction)fetchData:(id)sender {
  //  [self getImages];
  //}
  
-(void) getImages {
  // start spinner
  [self startSpinner:self :_spinner];
  
  [[HTTPService instance]getImages:^(NSDictionary * _Nullable dataDict, NSString * _Nullable errMessage) {
    if (dataDict) {
      NSLog(@"Dictionary: %@", dataDict.debugDescription);
      
      NSMutableArray *array = [[NSMutableArray alloc]init];
      
      if(dataDict.count > 0) {
        NSDictionary *photos = [dataDict valueForKey:@"photos"];
        if(photos) {
          NSArray *photo = [photos valueForKey:@"photo"];
          if(photo) {
            for (NSDictionary *images in photo) {
              Image *image = [[Image alloc]init];
              image.imageId = [images objectForKey:@"id"];
              image.imageURL = [images objectForKey:@"url_t"];
              
              [array addObject:image];
            }
          }
        }
      }
      
      // Add to the list
      self.imageList = array;
      
      //[self.imageList addObjectsFromArray:array];
      
      //NSLog(@"ImageList Count: %@",[@(self.imageList.count) stringValue]);
      
      [self updateCollectionViewData];
      
    } else if (errMessage){
      NSLog(@"Error: %@", errMessage);
    }
  }];
}
  
#pragma mark - Helper methods
-(void) updateCollectionViewData {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.collectionView reloadData];
    [self stopSpinner:self :_spinner];
  });
}
  
  
#pragma mark Start/Show spinner
-(void) startSpinner:(UIViewController *)controller :(UIActivityIndicatorView*)activityIndicator {
  [activityIndicator setCenter:(controller.view.center)];
  [activityIndicator setHidesWhenStopped:true];
  [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
  
  [[self collectionView]setAlpha:0.6];
  
  //  for (UIView *subview in controller.view.subviews) {
  //    [subview setAlpha:0.6];
  //  }
  
  [[self collectionView]setBackgroundColor:[UIColor darkGrayColor]];
  [controller.view addSubview:activityIndicator];
  [activityIndicator setAlpha:1.0];
  [activityIndicator startAnimating];
}
  
#pragma mark Stop/Hide spinner
-(void) stopSpinner:(UIViewController *)controller :(UIActivityIndicatorView*)activityIndicator {
  if (activityIndicator.isAnimating) {
    
    [[self collectionView]setBackgroundColor:[UIColor whiteColor]];
    [[self collectionView]setAlpha:1.0];
    //    for (UIView *subview in controller.view.subviews) {
    //      [subview setAlpha:1.0];
    //    }
    [activityIndicator stopAnimating];
  }
}
  
  
  
  
#pragma mark - Collection view data source
  
#pragma mark numberOfItemsInSection
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.imageList.count;
}
  
  
#pragma mark cellForItemAtIndexPath
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  
  NSString *cellIdentifier = @"ImageCell";
  ImageCell * cell = (ImageCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
  
  if (!cell) {
    cell = [[ImageCell alloc]init];
  }
  
  Image *sharkImage = [self.imageList objectAtIndex:indexPath.row];
  [cell updateUI:sharkImage];
  
  
  
  return cell;
}
  
#pragma mark - Collection view delegate
  
#pragma mark didSelectItemAtIndexPath
  /*
   - (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
   NSString *selected = [self.imageList objectAtIndex:indexPath.row];
   NSLog(@"selected=%@", selected);
   }
   */
  
  @end

