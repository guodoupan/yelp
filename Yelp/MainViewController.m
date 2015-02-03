//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "BusinessTableViewCell.h"
#import "SVProgressHUD.h"
#import "FilterViewController.h"
#import "BusinessAnnotation.h"
#import "UIImageView+AFNetworking.h"
#import "MapKit/MapKit.h"

NSString * const kYelpConsumerKey = @"kHaK3izYyinUJfMP2CAHNA";
NSString * const kYelpConsumerSecret = @"OtssoRAZem7e53Gw_d71d6XoLck";
NSString * const kYelpToken = @"6Yy9b_c_gj7kVVGwuZzLOh61BYkgaTlL";
NSString * const kYelpTokenSecret = @"1XioZg980nz_fmqF52xRVLqRdc4";

static int PageLimit = 20;
static int PrefetchOffset = 10;

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FilterViewControllerDelegate, MKMapViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *resultTable;
@property (weak, nonatomic) IBOutlet UILabel *noResultLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) BusinessTableViewCell *protoTypeCell;

@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSMutableArray *businessArray;

@property (nonatomic, strong) NSDictionary *filters;

@property (nonatomic, strong) NSString *searchTerm;

@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isMapShown;

-(void)search;;
-(void)onFilter;
-(void)onRightButton;
@end

@implementation MainViewController

- (BusinessTableViewCell *)protoTypeCell {
    if (!_protoTypeCell) {
        _protoTypeCell = [self.resultTable dequeueReusableCellWithIdentifier:@"BusinessTableViewCell"];
    }
    return _protoTypeCell;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        self.title = @"Yelp";
        
        UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStyleBordered target:self action:@selector(onFilter)];
        filterButton.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = filterButton;
        
        UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:self action:@selector(onRightButton)];
        mapButton.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = mapButton;
        

        
        float x = CGRectGetWidth(self.navigationItem.titleView.frame);
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(x, 0, x, CGRectGetHeight(self.navigationItem.titleView.frame))];
        searchBar.delegate = self;
        self.navigationItem.titleView = searchBar;
        
        self.searchTerm = @"chinese";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.businessArray) {
        self.businessArray = [NSMutableArray array];
    }

    self.resultTable.delegate = self;
    self.resultTable.dataSource = self;
    [self.resultTable registerNib:[UINib nibWithNibName:@"BusinessTableViewCell" bundle:nil]forCellReuseIdentifier:@"BusinessTableViewCell"];
    self.resultTable.rowHeight = UITableViewAutomaticDimension;
    
    self.noResultLabel.hidden = YES;
    
    self.total = 0;
    self.offset = 0;
    self.isLoading = false;
    self.isMapShown =  false;
    CLLocationCoordinate2D test = CLLocationCoordinate2DMake(37.774866,-122.394556);
    self.mapView.region = MKCoordinateRegionMakeWithDistance(test, 10000, 10000);
    self.mapView.hidden = true;
    self.mapView.delegate = self;

    [self search];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessTableViewCell"];

    cell.business = self.businessArray[indexPath.row];
    
    NSInteger loadedCount = self.businessArray.count;
    if (indexPath.row + PrefetchOffset > loadedCount && !self.isLoading && loadedCount < self.total) {
        self.offset += loadedCount;
        [self search];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.protoTypeCell.business = self.businessArray[indexPath.row];
    [self.protoTypeCell layoutIfNeeded];
    
    CGSize size = [self.protoTypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businessArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    self.searchTerm = searchBar.text;
    self.offset = 0;
    [self search];
}

- (void) showPinsOnMapView {
    NSArray * visibleIndexPaths = [self.resultTable indexPathsForVisibleRows];
    
    for (int i = 0; i < visibleIndexPaths.count; i++) {
        NSIndexPath *indexPath = visibleIndexPaths[i];
        [self.mapView addAnnotation:[self.businessArray[indexPath.row] asAnnotation]];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *mav = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MKPinAnnotationView"];
    mav.canShowCallout = YES;
    BusinessAnnotation *busAnno = (BusinessAnnotation *)annotation;
    UIImageView *ratingsImage;
    [ratingsImage setImageWithURL:busAnno.rating_img_url];
    return mav;
}

- (void)search{
    if (self.isLoading) {
        NSLog(@"isLoading, return");
        return;
    }
    NSMutableDictionary *parameters = [self.filters mutableCopy];
    [parameters setObject:@(self.offset) forKey:@"offset"];
    [parameters setObject:@(PageLimit) forKey:@"limit"];
    [self.client searchWithTerm:self.searchTerm andOptions:parameters success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"response: %@", response);
        NSArray *businessDictionary = response[@"businesses"];
        NSArray *businesses = [Business businessesWithDictionary:businessDictionary];
        if (self.offset == 0) {
            // refresh
            [self.businessArray removeAllObjects];
            [self.businessArray addObjectsFromArray:businesses];
            [self.resultTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:FALSE];
        } else {
            // load next page
            [self.businessArray addObjectsFromArray:businesses];
        }
        self.total = [response[@"total"] integerValue];
        if (self.total > 0) {
            [self.resultTable reloadData];
            self.noResultLabel.hidden = YES;
            self.resultTable.hidden = NO;
        } else {
            self.noResultLabel.hidden = NO;
            self.resultTable.hidden = YES;
        }
        [SVProgressHUD dismiss];
        self.isLoading = FALSE;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
        self.isLoading = FALSE;
        [SVProgressHUD dismiss];
    }];
    self.isLoading = true;
    [SVProgressHUD show];
}

- (void)onFilter {
    FilterViewController *vc = [[FilterViewController alloc] init];
    vc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nvc animated:YES completion:nil];
}


- (void)onRightButton {
    if (self.isMapShown) {
        self.navigationItem.rightBarButtonItem.title = @"Map";
        self.mapView.hidden = true;
        self.resultTable.hidden = false;
    } else {
        self.navigationItem.rightBarButtonItem.title = @"List";
        self.mapView.hidden = false;
        self.resultTable.hidden = true;
        [self showPinsOnMapView];
    }
    self.isMapShown = !self.isMapShown;
}

- (void)filtersViewController:(FilterViewController *)filtersViewControlller didChangeFilters:(NSDictionary *)filters {
    self.filters = filters;
    self.offset = 0;
    [self search];
}
@end
