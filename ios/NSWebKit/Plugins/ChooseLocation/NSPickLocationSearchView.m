//
//  NSPickLocationSearchView.m
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//

#import "NSPickLocationSearchView.h"
#import "Masonry.h"
#import "MJRefresh.h"
#import "NSPickLocationPOITableView.h"
#import "NSPickLocationSearchPOICell.h"
#import "UIImage+YYAdd.h"
#import "UIDevice+YYAdd.h"
#import "UIColor+YYAdd.h"

@implementation NSPlaceAroundTableView

@end

@interface NSPickLocationSearchView ()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, NSPickLocationPOITableViewGestureRecognizerDelegate> {
}
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSPickLocationPOITableView *tableView;
@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) NSMutableArray<AMapPOI *> *pois;//根据经纬度搜索的poi结果
@property (nonatomic, strong) NSMutableArray<AMapPOI *> *keyword_pois;//关键字搜索结果
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger keywordCurrentPage;

@property (nonatomic,strong)NSIndexPath *preSelectedIndexPath;
@property (nonatomic,strong,nullable )AMapPOI *currentSelectedPOI;
@end

@implementation NSPickLocationSearchView

- (id)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];

//        self.searchBar.backgroundImage = [UIImage imageWithColor:[UIColor redColor]];
        self.searchBar.delegate = self;
        self.searchBar.placeholder = @"搜索地点";

        //更改UISearchBarBackground
        self.searchBar.barTintColor = [UIColor blueColor];
        //去除边框线
        [self.searchBar setBackgroundImage:[UIImage new]];
        //更改TextField
        UIView *searchTextField =  [[[self.searchBar.subviews firstObject] subviews] lastObject];
        if([UIDevice systemVersion] >= 13){
            searchTextField.backgroundColor = [UIColor whiteColor];
        }
        else{
            searchTextField.backgroundColor = [UIColor colorWithHexString:@"eeeef0"];
        }
        
        //        searchTextField.layer.cornerRadius = 15;
        //        searchTextField.layer.masksToBounds = YES;
        [self addSubview:self.searchBar];


        [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.right.equalTo(self).offset(-10);
            make.height.equalTo(@60);
            make.top.equalTo(@20);
        }];


        self.tableView = [[NSPickLocationPOITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.gestureRecoginzerDelegate = self;
        self.tableView.tableFooterView = [UIView new];
        [self addSubview:self.tableView];

        //        self.tableView.panGestureRecognizer.delegate = self;

        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.top.equalTo(self.searchBar.mas_bottom);
        }];

        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                switch (self.resultDataType) {
                    case NSPickLocationSearchViewResultNormalType:{
                        
                        self.currentPage++;
                        [self loadMorePOIData:self.currentPage];
                    }
                    break;

                    case NSPickLocationSearchViewResultKeywordType:{
                        self.keywordCurrentPage ++;
                        [self searchPoiWithKeywords:self.searchBar.text page:self.keywordCurrentPage];
                    }
                    break;

                    default:
                        break;
                }

            });
            
        }];

        [footer setTitle:@"" forState:MJRefreshStateIdle];
        [footer setTitle:@"" forState:MJRefreshStateNoMoreData];

        footer.refreshingTitleHidden = YES;
        self.tableView.mj_footer = footer;


        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:panGesture];
        panGesture.delegate = self;


        self.search = [[AMapSearchAPI alloc] init];
        self.search.delegate = self;

        self.pois = @[].mutableCopy;
        self.keyword_pois = @[].mutableCopy;
    }

    return self;
}

#pragma mark - get
- (NSString *)mapSearchTypes {
    if (_mapSearchTypes.length == 0) {
        return @"050000|060000|070000|080000|090000|100000|110000|120000|130000|140000|160000|170000";
    }

    return _mapSearchTypes;
}

-(void)setResultDataType:(NSPickLocationSearchViewResultDataType)resultDataType{
    
    if(_resultDataType != resultDataType){
        _resultDataType = resultDataType;
        if(resultDataType == NSPickLocationSearchViewResultKeywordType){
            self.currentSelectedPOI = nil;
        }
        if(self.delegate && [self.delegate respondsToSelector:@selector(searchViewResultDataTypeChanged:)]){
            [self.delegate searchViewResultDataTypeChanged:resultDataType];
        }
    }
    
}

-(void)setCurrentSelectedPOI:(AMapPOI *)currentSelectedPOI{
    _currentSelectedPOI = currentSelectedPOI;
    if(self.delegate && [self.delegate respondsToSelector:@selector(searchViewCurrentSelectedPOIChanged:)]){
        [self.delegate searchViewCurrentSelectedPOIChanged:_currentSelectedPOI];
    }
}

/*
   // Only override drawRect: if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   - (void)drawRect:(CGRect)rect {
   // Drawing code
   }
 */

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];

    [self changeExpandState:NSPickLocationSearchViewExpand];
    self.resultDataType = NSPickLocationSearchViewResultKeywordType;
    
    [self.tableView reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.currentSelectedPOI = nil;
    [self.keyword_pois removeAllObjects];
    self.keywordCurrentPage = 1;

    if (searchText.length > 0) {
        [self searchPoiWithKeywords:searchText page:self.keywordCurrentPage];
    } else {
        [self.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    self.currentSelectedPOI = nil;
    [self.keyword_pois removeAllObjects];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self changeExpandState:NSPickLocationSearchViewUnExpand];
    self.resultDataType = NSPickLocationSearchViewResultNormalType;
    [self.tableView reloadData];
 
    [self selectPOIWithIndex:self.preSelectedIndexPath.row];
    [self.tableView selectRowAtIndexPath:self.preSelectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
   
   
    self.currentSelectedPOI = nil;
    [self.keyword_pois removeAllObjects];
    [self.tableView reloadData];
    self.keywordCurrentPage = 0;

    if (self.searchBar.text.length > 0) {
        [self changeExpandState:NSPickLocationSearchViewUnExpand];
        [self.tableView.mj_footer beginRefreshing];

        
    } else {
        
    }

    [self searchBarResignFirstResponder];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked)]) {
        [self.delegate searchBarSearchButtonClicked];
    }
}
-(void)searchBarResignFirstResponder{
    [self.searchBar resignFirstResponder];
    UIButton *cancelBtn = [self.searchBar valueForKey:@"cancelButton"]; //首先取出cancelBtn
    cancelBtn.enabled = YES;
}

#pragma mark - UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;

    switch (self.resultDataType) {
        case NSPickLocationSearchViewResultNormalType:{
            count = self.pois.count;
        }
        break;

        case NSPickLocationSearchViewResultKeywordType:{
            count = self.keyword_pois.count;
        }
        break;

        default:
            break;
    }
//    tableView.hidden = count == 0;
    return count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSPickLocationSearchPOICell *cell = [tableView dequeueReusableCellWithIdentifier:@"poiCell"];

    if (cell == nil) {
        cell = [[NSPickLocationSearchPOICell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"poiCell"];
    }
    cell.keywords = self.searchBar.text;
    
    
    switch (self.resultDataType) {
        case NSPickLocationSearchViewResultNormalType:{
            cell.currentPOISearchCoordinate = self.currentPOISearchCoordinate;
            AMapPOI *poi = self.pois[indexPath.row];
            cell.poi = poi;
        }
        break;

        case NSPickLocationSearchViewResultKeywordType:{
            cell.currentPOISearchCoordinate = self.currentGPSCoordinate;
            AMapPOI *poi = self.keyword_pois[indexPath.row];
            cell.poi = poi;
        }
        break;

        default:
            break;
    }
    


    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (self.resultDataType) {
        case NSPickLocationSearchViewResultNormalType:{
            self.preSelectedIndexPath = indexPath;
            break;
        }
        case NSPickLocationSearchViewResultKeywordType:{
            [self searchBarResignFirstResponder];
            [self changeExpandState:NSPickLocationSearchViewUnExpand];
        }
            break;
        default:
            break;
    }
    [self selectPOIWithIndex:indexPath.row];
}

#pragma mark - UIGestureRecognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.expandState == NSPickLocationSearchViewUnExpand) {
        if (gestureRecognizer.view == self) {
            return NO;
        }

        return YES;
    } else {
        if (gestureRecognizer.view == self) {
            if (self.tableView.contentOffset.y <= 0) {
                return NO;
            } else {
                return YES;
            }
        } else {
            return NO;
        }
    }

    return NO;
}

- (void)pan:(UIPanGestureRecognizer *)pan
{
    CGPoint offsetP = [pan translationInView:self];
    static CGFloat bottomViewStartOffset = 0;

    if (pan.state == UIGestureRecognizerStateBegan) {
        bottomViewStartOffset = self.frame.origin.y;
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        CGFloat offst = bottomViewStartOffset + offsetP.y;

        if (offst < NSPickLocationSearchViewExpandTopOffset) {
            offst = NSPickLocationSearchViewExpandTopOffset;
        } else if (offst > NSPickLocationSearchViewUnExpandTopOffset) {
            offst = NSPickLocationSearchViewUnExpandTopOffset;
        }

        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.superview);
            make.top.equalTo(self.superview).offset(offst);
        }];

        if (self.delegate && [self.delegate respondsToSelector:@selector(searchViewTopOffsetChanged:)]) {
            [self.delegate searchViewTopOffsetChanged:offst];
        }

        [UIView animateWithDuration:0.3
                         animations:^{
            [self.superview layoutIfNeeded];
        }];
    } else {
        if (self.expandState == NSPickLocationSearchViewUnExpand) {
            if (offsetP.y < -40) {
                [self changeExpandState:NSPickLocationSearchViewExpand];
            } else {
                [self changeExpandState:NSPickLocationSearchViewUnExpand];
            }
        } else {
            if (offsetP.y > 40) {
                [self changeExpandState:NSPickLocationSearchViewUnExpand];
            } else {
                [self changeExpandState:NSPickLocationSearchViewExpand];
            }
        }
    }
}

- (void)changeExpandState:(NSPickLocationSearchViewExpandState)state {
    self.expandState = state;

    if (state == NSPickLocationSearchViewExpand) {
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.superview);
            make.top.equalTo(self.superview).offset(NSPickLocationSearchViewExpandTopOffset);
        }];

        if (self.delegate && [self.delegate respondsToSelector:@selector(searchViewTopOffsetChanged:)]) {
            [self.delegate searchViewTopOffsetChanged:NSPickLocationSearchViewExpandTopOffset];
        }
    } else {
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.superview);
            make.top.equalTo(self.superview).offset(NSPickLocationSearchViewUnExpandTopOffset);
        }];
        [self searchBarResignFirstResponder];

        if (self.delegate && [self.delegate respondsToSelector:@selector(searchViewTopOffsetChanged:)]) {
            [self.delegate searchViewTopOffsetChanged:NSPickLocationSearchViewUnExpandTopOffset];
        }
    }

    [UIView animateWithDuration:0.3
                     animations:^{
        [self.superview layoutIfNeeded];
    }];
}

#pragma mark - 根据中心点坐标来搜周边的POI.

- (void)searchPoiWithCenterCoordinate:(CLLocationCoordinate2D)coord
{
    self.currentPOISearchCoordinate = coord;
    self.currentSelectedPOI = nil;
    [self.pois removeAllObjects];
    [self.tableView reloadData];
    self.currentPage = 0;
    [self.tableView.mj_footer beginRefreshing];
}

- (void)loadMorePOIData:(NSInteger)page {
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];

    request.location = [AMapGeoPoint locationWithLatitude:self.currentPOISearchCoordinate.latitude longitude:self.currentPOISearchCoordinate.longitude];

    request.radius = 1000;
    request.types = self.mapSearchTypes;
    request.sortrule = 0;
    request.page = page;
    [self.search AMapPOIAroundSearch:request];
}

#pragma mark - 根据关键字来搜周边的POI.
- (void)searchPoiWithKeywords:(NSString *)keywords page:(NSInteger)page {
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];

    request.location = [AMapGeoPoint locationWithLatitude:self.currentGPSCoordinate.latitude longitude:self.currentGPSCoordinate.longitude];
    request.keywords = keywords;
    request.radius = 50000;
    request.types = self.mapSearchTypes;
    request.sortrule = 0;
    request.page = page;
    [self.search AMapPOIAroundSearch:request];
}


#pragma mark -

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    if (self.resultDataType == NSPickLocationSearchViewResultNormalType) {
        [self.pois addObjectsFromArray:response.pois];
    } else {
        [self.keyword_pois addObjectsFromArray:response.pois];
    }

    [self.tableView reloadData];

    // 结束刷新
    if (response.pois.count == 0) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.tableView.mj_footer endRefreshing];
    }

    if (self.resultDataType == NSPickLocationSearchViewResultNormalType) {
        if (request.page == 1) {
            self.preSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            self.currentSelectedPOI = self.pois.firstObject;
            //自动选择第一个
            [self.tableView selectRowAtIndexPath:self.preSelectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop ];
        }
    }
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
}

#pragma mark - action
- (void)selectPOIWithIndex:(NSInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchViewSelectedPOIChanged:isFirstPOI:)]) {
        switch (self.resultDataType) {
            case NSPickLocationSearchViewResultNormalType:{
                self.currentSelectedPOI = self.pois[index];
                [self.delegate searchViewSelectedPOIChanged:self.pois[index] isFirstPOI:index == 0 ? YES : NO];
            }
            break;

            case NSPickLocationSearchViewResultKeywordType:{
                self.currentSelectedPOI = self.keyword_pois[index];
                [self.delegate searchViewSelectedPOIChanged:self.keyword_pois[index] isFirstPOI:NO];
            }
            break;

            default:
                break;
        }
    }
}

/// 获取当前选中的POI
- (AMapPOI *)getCurrentSelectedPOI {

    return self.currentSelectedPOI;
}

@end
