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

NSString * const kYelpConsumerKey = @"kHaK3izYyinUJfMP2CAHNA";
NSString * const kYelpConsumerSecret = @"OtssoRAZem7e53Gw_d71d6XoLck";
NSString * const kYelpToken = @"6Yy9b_c_gj7kVVGwuZzLOh61BYkgaTlL";
NSString * const kYelpTokenSecret = @"1XioZg980nz_fmqF52xRVLqRdc4";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *resultTable;

@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSArray *resultArray;
@property (nonatomic, strong) NSArray *businessArray;

-(void)searchWithTeam:(NSString *)term;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
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
    // Do any additional setup after loading the view from its nib.
    
    self.searchBar.delegate = self;
    [self searchWithTeam:@"chinese"];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businessArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self searchWithTeam:searchBar.text];
}

- (void)searchWithTeam:(NSString *)term {
    [self.client searchWithTerm:term success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"response: %@", response);
        NSArray *businessDictionary = response[@"businesses"];
        self.businessArray = [Business businessesWithDictionary:businessDictionary];
        
        self.resultArray = response[@"businesses"];
        NSInteger total = [response[@"total"] integerValue];
        NSLog(@"total= %d", total);
        [self.resultTable reloadData];
        [SVProgressHUD dismiss];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
        [SVProgressHUD dismiss];
    }];
    [SVProgressHUD show];
}
@end
