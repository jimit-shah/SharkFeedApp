//
//  ViewController.m
//  SharkFeedApp
//
//  Created by Jimit Shah on 2/17/18.
//  Copyright © 2018 Jimit Shah. All rights reserved.
//

#import "FeedsViewController.h"
#import "AppDelegate.h"
#import "HTTPService.h"
#import "Image.h"
#import "ImageCell.h"
//#import "CollectionViewFlowLayout.h"

@interface FeedsViewController () {
  AppDelegate *appDelegate;
  NSManagedObjectContext *context;
  CGFloat inset;
  CGFloat spacing;
  CGFloat lineSpacing;
}
  
#pragma mark - Properties
  
  @property (strong, nonatomic) NSMutableArray *imageList;
  @property (strong, nonatomic) UIActivityIndicatorView *spinner;
  @property (strong, nonatomic) UIImage *logo;
  @property (strong, nonatomic) UIImageView *titleImageView;
  
#pragma mark - Outlets
  
  @property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
//  @property (weak, nonatomic) IBOutlet CollectionViewFlowLayout *flowLayout;
//  @property (weak, nonatomic) IBOutlet CollectionViewFlowLayout *flowLayout;
//
//  @property (weak, nonatomic) IBOutlet CollectionViewFlowLayout *flowLayout;
  @property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
  
  @end

@implementation FeedsViewController
  
#pragma mark - Lifecycle
  
- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.collectionView.dataSource = self;
  self.collectionView.delegate = self;
  
  if (_imageList == nil) {
    _imageList = [[NSMutableArray alloc]init];
  }
  // configure UI
  [self configureUI];
  
  // get Images and reload collection view
  [self getImages];
  
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  
  [self.collectionView.collectionViewLayout invalidateLayout];
  [self.flowLayout invalidateLayout];
}
  
- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  
  if(UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation)) {
    
  } else {
    
  }
// [self.flowLayout invalidateLayout];
  [self.collectionView.collectionViewLayout invalidateLayout];
  [[self collectionView].collectionViewLayout invalidateLayout];
  [[self collectionView] reloadData];
  
    
}
#pragma mark - Actions
  
  
  
#pragma mark fetchImages
  
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
              image.imageURL = [images objectForKey:@"url_c"];
              
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

# pragma makr configureUI
- (void)configureUI {
  inset = 15.0;
  spacing = 5.0;
  lineSpacing = 5.0;
  
  self.spinner = [[UIActivityIndicatorView alloc]init];
  self.logo = [UIImage imageNamed:@"SharkFeed_logosmall"];
  self.titleImageView = [[UIImageView alloc] initWithImage:[self logo]] ;
  self.navigationItem.titleView = [self titleImageView];
}
  
#pragma mark Start/Show spinner
-(void) startSpinner:(UIViewController *)controller :(UIActivityIndicatorView*)activityIndicator {
  [activityIndicator setCenter:(controller.view.center)];
  [activityIndicator setHidesWhenStopped:true];
  [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
  
  [[self collectionView]setAlpha:0.6];
  
  
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
  
  
#pragma mark - UICollection View Flow Layout
  
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  CGFloat screenWidth = screenRect.size.width;
  CGFloat screenHeight = screenRect.size.height;
  float cellWidth = 0;
  
  // define number of columns based on potrait/landscape mode.
  if (screenWidth > screenHeight) {
    cellWidth = ((screenWidth) / 5.0 - (inset + spacing));
  } else {
    cellWidth = ((screenWidth) / 3.0 - (inset + spacing));
  }
  
  CGSize size = CGSizeMake(cellWidth, cellWidth);
  return size;
}
  
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
  
  return UIEdgeInsetsMake(inset, inset, inset, inset);
}
  
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
  
  return inset;
}
  
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
  
  return inset;
}
  
  
  @end

