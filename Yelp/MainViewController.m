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

NSString * const kYelpConsumerKey = @"kHaK3izYyinUJfMP2CAHNA";
NSString * const kYelpConsumerSecret = @"OtssoRAZem7e53Gw_d71d6XoLck";
NSString * const kYelpToken = @"6Yy9b_c_gj7kVVGwuZzLOh61BYkgaTlL";
NSString * const kYelpTokenSecret = @"1XioZg980nz_fmqF52xRVLqRdc4";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FilterViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *resultTable;
@property (weak, nonatomic) IBOutlet UILabel *noResultLabel;
@property (nonatomic, strong) BusinessTableViewCell *protoTypeCell;

@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSArray *resultArray;
@property (nonatomic, strong) NSArray *businessArray;

@property (nonatomic, strong) NSDictionary *filters;

-(void)searchWithTeam:(NSString *)term andOptions:(NSDictionary *)options;
-(void)onFilter;

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
        
        float x = CGRectGetWidth(self.navigationItem.titleView.frame);
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(x, 0, x, CGRectGetHeight(self.navigationItem.titleView.frame))];
        searchBar.delegate = self;
        self.navigationItem.titleView = searchBar;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.resultTable.delegate = self;
    self.resultTable.dataSource = self;
    [self.resultTable registerNib:[UINib nibWithNibName:@"BusinessTableViewCell" bundle:nil]forCellReuseIdentifier:@"BusinessTableViewCell"];
    self.resultTable.rowHeight = UITableViewAutomaticDimension;
    
    self.noResultLabel.hidden = YES;
    
    [self searchWithTeam:@"chinese" andOptions:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessTableViewCell"];

    cell.business = self.businessArray[indexPath.row];
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
    [self searchWithTeam:searchBar.text andOptions:nil];
}

- (void)searchWithTeam:(NSString *)term andOptions:(NSDictionary *)options{
    [self.client searchWithTerm:term andOptions:options success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"response: %@", response);
        NSArray *businessDictionary = response[@"businesses"];
        self.businessArray = [Business businessesWithDictionary:businessDictionary];
        
        self.resultArray = response[@"businesses"];
        NSInteger total = [response[@"total"] integerValue];
        if (total > 0) {
            [self.resultTable reloadData];
            self.noResultLabel.hidden = YES;
            self.resultTable.hidden = NO;
        } else {
            self.noResultLabel.hidden = NO;
            self.resultTable.hidden = YES;
        }
        [SVProgressHUD dismiss];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
        [SVProgressHUD dismiss];
    }];
    [SVProgressHUD show];
}

- (void)onFilter {
    FilterViewController *vc = [[FilterViewController alloc] init];
    vc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)filtersViewController:(FilterViewController *)filtersViewControlller didChangeFilters:(NSDictionary *)filters {
    self.filters = filters;
    [self searchWithTeam:@"chinese" andOptions:filters];
}
@end
