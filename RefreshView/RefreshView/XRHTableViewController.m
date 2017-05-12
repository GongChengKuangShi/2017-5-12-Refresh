//
//  XRHTableViewController.m
//  RefreshView
//
//  Created by xiangronghua on 2017/5/12.
//  Copyright © 2017年 xiangronghua. All rights reserved.
//

#import "XRHTableViewController.h"
#import "XRHRefresh.h"

@interface XRHTableViewController ()

@property (weak, nonatomic) XRHRefreshHeaderView * refreshHeader;
@property (weak, nonatomic) XRHRefreshFooterView *refreshFooter;

@property (nonatomic, assign) NSInteger totalRowCount;

@end

@implementation XRHTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"上拉和下拉刷新";
        self.tableView.rowHeight = 60.0f;
        self.tableView.separatorColor = [UIColor whiteColor];
        // 模拟数据
        _totalRowCount = 10;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupHeader];
    [self setupFooter];

}

- (void)setupHeader {
    XRHRefreshHeaderView *refreshHeader = [XRHRefreshHeaderView refreshView];
    
    //     默认是在navigationController环境下，如果不是在此环境下，请设置 refreshHeader.isEffectedByNavigationController = NO;
    [refreshHeader addToScrollView:self.tableView];
    //    [refreshHeader addToScrollView:self.tableView isEffectedByNavigationController:NO];
    
    __weak XRHRefreshHeaderView *weakRefreshHeader = refreshHeader;
    __weak typeof(self) weakSelf = self;
    refreshHeader.beginRefreshingOperation = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.totalRowCount += 3;
            [weakSelf.tableView reloadData];
            [weakRefreshHeader endRefreshing];
        });
    };
    
    // 进入页面自动加载一次数据
    [refreshHeader autoRefreshWhenViewDidAppear];
}

- (void)setupFooter {
    XRHRefreshFooterView *refreshFooter = [XRHRefreshFooterView refreshView];
    [refreshFooter addToScrollView:self.tableView];
    //    [refreshFooter addToScrollView:self.tableView isEffectedByNavigationController:NO];
    [refreshFooter addTarget:self refreshAction:@selector(footerRefresh)];
    _refreshFooter = refreshFooter;
}


- (void)footerRefresh
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.totalRowCount += 2;
        [self.tableView reloadData];
        [self.refreshFooter endRefreshing];
    });
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.totalRowCount;;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *ID = @"test";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.backgroundView = nil;
        cell.textLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.95f];
    }
    
    cell.backgroundColor = [self randomColor];
    cell.textLabel.text = [NSString stringWithFormat:@"------第%ld行--共%ld行----", indexPath.row + 1, self.totalRowCount];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController pushViewController:[XRHTableViewController new] animated:YES];
}

- (UIColor *)randomColor
{
    CGFloat r = arc4random_uniform(255);
    CGFloat g = arc4random_uniform(255);
    CGFloat b = arc4random_uniform(255);
    
    return [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:0.3f];
}

@end
