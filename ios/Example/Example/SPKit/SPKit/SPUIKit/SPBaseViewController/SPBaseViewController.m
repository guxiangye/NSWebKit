//
//  SPBaseViewController.m
//  SPKit
//
//  Created by 高鹏程 on 2023/4/24.
//

#import "SPBaseViewController.h"

@interface SPBaseViewController ()

@end

@implementation SPBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - 视图控制器生命周期
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:[self prefersNavigationBarHidden] animated:animated];
}

- (BOOL)prefersNavigationBarHidden {
    return NO;
}

@end
