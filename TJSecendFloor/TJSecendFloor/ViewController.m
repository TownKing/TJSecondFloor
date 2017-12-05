//
//  ViewController.m
//  TJSecendFloor
//
//  Created by 李琼 on 2017/1/1.
//  Copyright © 2017年 Town. All rights reserved.
//

#import "ViewController.h"
#import "TJCommunityCoverTVC.h"
#import "TJCommunityIndexPageTVC.h"
#import "TJCommunitySplitStyleCell.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>{
    CGFloat previousOffsetY;
    UIActivityIndicatorView *topAV;
    BOOL shoulRecognizeScroll;
    CGFloat refreshAreaHeight;//下拉多长进入二楼
}
@property (weak, nonatomic) IBOutlet UITableView *mytab;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mytab.dataSource = self;
    _mytab.delegate = self;
    [self configPanGesture];
    previousOffsetY = 0;
    refreshAreaHeight = 110;
    [_mytab registerNib:[UINib nibWithNibName:@"TJCommunityCoverTVC" bundle:nil] forCellReuseIdentifier:@"coverCell"];
    [_mytab registerNib:[UINib nibWithNibName:@"TJCommunityIndexPageTVC" bundle:nil] forCellReuseIdentifier:@"indexPageCell"];
    [_mytab registerNib:[UINib nibWithNibName:@"TJCommunitySplitStyleCell" bundle:nil] forCellReuseIdentifier:@"splitCell"];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated{
    _mytab.contentOffset = CGPointMake(0, kScreenHeight);

}

- (void)configPanGesture{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [_mytab addGestureRecognizer:pan];
}
- (void)pan: (UIPanGestureRecognizer *)pan{
    
        NSLog(@"currentOffsety:%f",_mytab.contentOffset.y);
        CGFloat currentOffset = _mytab.contentOffset.y;
    if (pan.state ==UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        CGFloat velocity = [pan velocityInView:_mytab].y;

        if (currentOffset > kScreenHeight - refreshAreaHeight && currentOffset < kScreenHeight) {
            if (velocity > 0) {
                [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.3 options:UIViewAnimationOptionCurveLinear animations:^{
                    [_mytab setContentOffset:CGPointMake(0, kScreenHeight) animated:true];

                } completion:^(BOOL finished) {
                    
                }];
            }
        }else if(currentOffset < kScreenHeight - refreshAreaHeight){
            NSLog(@"v:%f",velocity);
            //-200为下滑手势的最低加速值
            if (velocity >= -200.0) {
                [_mytab setContentOffset:CGPointMake(0, 0) animated:true];
            }
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return true;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [UIScreen mainScreen].bounds.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"coverCell"];
        if (!topAV) {
            topAV = [cell viewWithTag:47];

        }
        
    }else if(indexPath.row == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"indexPageCell"];
        
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"splitCell"];
        
    }
    
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!shoulRecognizeScroll) {
        shoulRecognizeScroll = true;
        return;
    }
    NSLog(@"currentOffsety:%f",_mytab.contentOffset.y);
    CGFloat currentOffset = _mytab.contentOffset.y;
    if (currentOffset > kScreenHeight - refreshAreaHeight && currentOffset < kScreenHeight) {
        CGFloat delta = previousOffsetY - currentOffset;
       
        
        NSLog(@"delta:%f,deltaRate:%f",delta,(refreshAreaHeight -(kScreenHeight - currentOffset)) / (refreshAreaHeight));
        
        if (delta > 0) {
            topAV.hidden = false;
            [topAV startAnimating];
            //speedRate为下拉阻尼系数
            CGFloat speedRate = delta * (refreshAreaHeight -(kScreenHeight - currentOffset)) / (refreshAreaHeight) / 10;
            
            NSLog(@"sr:%f",speedRate);
            [_mytab setContentOffset:CGPointMake(0, currentOffset + speedRate)];
        }
    }else{
        topAV.hidden = true;
    }
    
    previousOffsetY = _mytab.contentOffset.y;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
