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
#pragma mark - Properties
//@property (strong, nonatomic) Image *image;
//@property(nonatomic,strong) NSString *imageURL;
//@property(nonatomic,strong) NSString *imageId;
@end

@implementation LightBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageData = [[Image alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)downloadTapped:(UIButton *)sender {
}
- (IBAction)openTapped:(UIButton *)sender {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
