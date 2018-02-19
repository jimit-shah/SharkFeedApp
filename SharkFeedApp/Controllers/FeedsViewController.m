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
#import "LightBoxViewController.h"


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
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIImageView *pullToRefreshImageView;

@property (nonatomic, strong) UIView *refreshLoadingView;
@property (nonatomic, strong) UIView *refreshColorView;
@property (nonatomic, strong) UIImageView *refresh_background;
@property (nonatomic, strong) UIImageView *refresh_spinner;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (assign) BOOL isRefreshIconsOverlap;

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@end

@implementation FeedsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.collectionView.dataSource = self;
  self.collectionView.delegate = self;
  
  // setup refresh control
  [self setupRefreshControl];
  
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

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                               duration:(NSTimeInterval)duration{
  [self.collectionView.collectionViewLayout invalidateLayout];
  [self.flowLayout invalidateLayout];
}


#pragma mark - setup Refresh Control

- (void)setupRefreshControl
{
  // Create a UIRefreshControl
  self.refreshControl = [[UIRefreshControl alloc] init];
  
  // Setup the loading view, which will hold the moving graphics
  self.refreshLoadingView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
  self.refreshLoadingView.backgroundColor = [UIColor clearColor];
  
  // Setup the color view, which will display the rainbowed background
  self.refreshColorView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
  self.refreshColorView.backgroundColor = [UIColor clearColor];
  self.refreshColorView.alpha = 0.30;
  
  // Create the graphic image views
  self.refresh_background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Pull to refresh 2"]];
  self.refresh_spinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Pull to refresh 1"]];
  
  self.refreshLabel = [[UILabel alloc]initWithFrame:self.refreshControl.bounds];
  self.refreshLabel.text = @"Pull to refresh sharks";
  self.refreshLabel.textAlignment = NSTextAlignmentCenter;
  self.refreshLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
  self.refreshLabel.textColor = [UIColor darkGrayColor];
  
  // Add the graphics to the loading view
  [self.refreshLoadingView addSubview:self.refresh_background];
  [self.refreshLoadingView addSubview:self.refresh_spinner];
  [self.refreshLoadingView addSubview:self.refreshLabel];
  
  // Clip so the graphics don't stick out
  self.refreshLoadingView.clipsToBounds = YES;
  
  // Hide the original spinner icon
  self.refreshControl.tintColor = [UIColor clearColor];
  
  // Add the loading and colors views to our refresh control
  [self.refreshControl addSubview:self.refreshColorView];
  [self.refreshControl addSubview:self.refreshLoadingView];
  
  // Initalize flags
  self.isRefreshIconsOverlap = NO;
  
  // When activated, invoke our refresh function
  [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
  [self.collectionView addSubview:self.refreshControl];
  
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  // Get the current size of the refresh controller
  CGRect refreshBounds = self.refreshControl.bounds;
  
  // Distance the table has been pulled >= 0
  CGFloat pullDistance = MAX(0.0, -self.refreshControl.frame.origin.y);
  
  // Half the width of the table
  CGFloat midX = self.collectionView.frame.size.width / 2.0;
  
  // Calculate the width and height of our graphics
  CGFloat compassHeight = self.refresh_background.bounds.size.height;
  CGFloat compassHeightHalf = compassHeight / 2.0;
  
  CGFloat compassWidth = self.refresh_background.bounds.size.width;
  CGFloat compassWidthHalf = compassWidth / 2.0;
  
  CGFloat spinnerHeight = self.refresh_spinner.bounds.size.height;
  CGFloat spinnerHeightHalf = spinnerHeight / 2.0;
  
  CGFloat spinnerWidth = self.refresh_spinner.bounds.size.width;
  CGFloat spinnerWidthHalf = spinnerWidth / 2.0;
  
  CGFloat labelHeight = self.refreshLabel.bounds.size.height;
  CGFloat labelHeightHalf = labelHeight / 2.0;
  
  CGFloat labelWidth = self.refreshLabel.bounds.size.width;
  CGFloat labelWidthHalf = labelWidth / 2.0;
  
  // Calculate the pull ratio, between 0.0-1.0
  CGFloat pullRatio = MIN( MAX(pullDistance, 0.0), 100.0) / 100.0;
  
  // Set the Y coord of the graphics, based on pull distance
  CGFloat spinnerY = pullDistance / 5.0 - spinnerHeightHalf;
  CGFloat compassY = pullDistance / 2.0 - compassHeightHalf;
  CGFloat labelY = pullDistance / 1.1 - labelHeightHalf;
  
  // Calculate the X coord of the graphics, adjust based on pull ratio
  CGFloat compassX = (midX + compassWidthHalf) - (compassWidth * pullRatio);
  CGFloat spinnerX = (midX + spinnerWidthHalf) - (spinnerWidth * pullRatio);
  //CGFloat spinnerX = (midX - spinnerWidth - spinnerWidthHalf) + (spinnerWidth * pullRatio);
  CGFloat labelX = (midX - labelWidth - labelWidthHalf) + (labelWidth * pullRatio);
  
  // When the compass and spinner overlap, keep them together
  if (fabs(compassX - spinnerX) < 1.0) {
    self.isRefreshIconsOverlap = YES;
  }
  
  // If the graphics have overlapped or we are refreshing, keep them together
  if (self.isRefreshIconsOverlap || self.refreshControl.isRefreshing) {
    compassX = midX - compassWidthHalf;
    spinnerX = midX - spinnerWidthHalf;
    labelX = midX - labelWidthHalf;
  }
  
  // Set the graphic's frames
  CGRect compassFrame = self.refresh_background.frame;
  compassFrame.origin.x = compassX;
  compassFrame.origin.y = compassY;
  
  CGRect spinnerFrame = self.refresh_spinner.frame;
  spinnerFrame.origin.x = spinnerX;
  spinnerFrame.origin.y = spinnerY;
  
  CGRect labelFrame = self.refreshLabel.frame;
  labelFrame.origin.x = labelX;
  labelFrame.origin.y = labelY;
  
  self.refresh_background.frame = compassFrame;
  self.refresh_spinner.frame = spinnerFrame;
  self.refreshLabel.frame = labelFrame;
  
  // Set the encompassing view's frames
  refreshBounds.size.height = pullDistance;
  
  self.refreshColorView.frame = refreshBounds;
  self.refreshLoadingView.frame = refreshBounds;
  
  // If we're refreshing and the animation is not playing, then play the animation
  if (self.refreshControl.isRefreshing) {
    // Change the background color
    self.refreshColorView.backgroundColor = [UIColor lightGrayColor];
  }
  
  NSLog(@"pullDistance: %.1f, pullRatio: %.1f, midX: %.1f, isRefreshing: %i", pullDistance, pullRatio, midX, self.refreshControl.isRefreshing);
}

#pragma mark - Refresh data with UIRefreshControl

- (void)refreshView:(UIRefreshControl *)refresh {
  
  // refresh data
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
              image.imageLURL = [images objectForKey:@"url_l"];
              image.imageOURL = [images objectForKey:@"url_o"];
              image.title = [images objectForKey:@"title"];
              [array addObject:image];
            }
          }
        }
      }
      // Replace data with new data
      self.imageList = array;
      
      //NSLog(@"ImageList Count: %@",[@(self.imageList.count) stringValue]);
      
      dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Done");
        [self.collectionView reloadData];
        [refresh endRefreshing];
        [self resetRefreshControl];
      });
      
    } else if (errMessage){
      NSLog(@"Error: %@", errMessage);
    }
  }];
}

- (void) resetRefreshControl {
  // Reset our flags and background color
  self.isRefreshIconsOverlap = NO;
  self.refreshColorView.backgroundColor = [UIColor clearColor];
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
              image.imageURL = [images objectForKey:@"url_t"];
              image.imageLURL = [images objectForKey:@"url_l"];
              image.imageOURL = [images objectForKey:@"url_o"];
              image.title = [images objectForKey:@"title"];
              [array addObject:image];
            }
          }
        }
      }
      
      // Add to the list
      //self.imageList = array;
      
      [self.imageList addObjectsFromArray:array];
      
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
  lineSpacing = 10.0;
  
  self.spinner = [[UIActivityIndicatorView alloc]init];
  self.logo = [UIImage imageNamed:@"SharkFeed_logosmall"];
  self.titleImageView = [[UIImageView alloc] initWithImage:[self logo]] ;
  self.navigationItem.titleView = [self titleImageView];
  [self.collectionView setBounces:YES];
  self.collectionView.alwaysBounceVertical = YES;
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

#pragma mark willDisplayCell
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.item == (self.imageList.count - 6)) {
    [self getImages];
  }
}

#pragma mark - Collection view delegate

#pragma mark didSelectItemAtIndexPath

 - (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

   Image *selectedImage = [self.imageList objectAtIndex:indexPath.row];
   NSLog(@"selected IMAGE_ID = %@", selectedImage.imageId);
   NSLog(@"selected imageURL = %@", selectedImage.imageURL);
   NSLog(@"selected TITLE = %@", selectedImage.title);
   
   LightBoxViewController *lightBoxViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LightBoxViewController"];
   lightBoxViewController.imageData = selectedImage;
   [self.navigationController pushViewController:lightBoxViewController animated:true];
 }



#pragma mark - UICollection View Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  CGFloat screenWidth = screenRect.size.width;
  CGFloat screenHeight = screenRect.size.height;
  float cellWidth = 0;
  float cellHeight = 0;
  
  // define number of columns based on potrait/landscape mode.
  if (screenWidth > screenHeight) {
    cellHeight = (screenWidth/6.0 - (inset + spacing));
    cellWidth = (screenWidth/6.0 - (inset));
  } else {
    cellWidth = (screenWidth/3.0 - (inset + spacing));
    cellHeight = cellWidth;
  }
  
  CGSize size = CGSizeMake(cellWidth, cellHeight);
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

