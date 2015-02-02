//
//  FilterViewController.m
//  Yelp
//
//  Created by Doupan Guo on 2/1/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FilterViewController.h"
#import "FilterCell.h"
#import "FilterDropdownCell.h"

static NSString *const TypeSegment = @"segment";
static NSString *const TypeSwitch = @"switch";
static NSString *const TypeDropdown = @"dropdown";

@interface FilterViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *filtersArray;
@property (nonatomic, strong) NSMutableIndexSet *expandedSections;

@property (nonatomic, assign) NSInteger selectedSort;
@property (nonatomic, assign) NSInteger selectedDistance;

- (void)onCancel;
- (void)onSearch;
- (void)initFilters;
- (FilterDropdownCell *)configureSortCell: (NSArray *)filters atIndexPath:(NSIndexPath *)indexPath selected:(NSInteger)index;
@end

@implementation FilterViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Filter";
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(onCancel)];
        cancelButton.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStyleBordered target:self action:@selector(onSearch)];
        searchButton.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = searchButton;
        
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.expandedSections) {
        self.expandedSections = [[NSMutableIndexSet alloc] init];
    }
    [self.tableView registerNib:[UINib nibWithNibName:@"FilterCell" bundle:nil]forCellReuseIdentifier:@"FilterCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FilterDropdownCell" bundle:nil]forCellReuseIdentifier:@"FilterDropdownCell"];
    [self initFilters];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSearch {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initFilters {
    self.filtersArray = [[NSMutableArray alloc] init];

    NSDictionary *popularDict = @{@"title":@"Most Popular", @"filters":@[@"Open Now", @"Hot & New", @"Offering a Deal", @"Delivery"], @"type":TypeSwitch};
    [self.filtersArray addObject:popularDict];
    
    NSDictionary *distanceDict = @{@"title":@"Distance", @"filters":@[@"Auto", @"0.3 miles", @"1 mile", @"5 miles", @"20 miles"], @"type":TypeDropdown, @"select":@"0"};
    [self.filtersArray addObject:distanceDict];
    
    NSDictionary *sortDict = @{@"title":@"Sort by", @"filters":@[@"Best Match", @"Distance", @"Rating", @"Most Reviewed"], @"type":TypeDropdown, @"select":@"0"};
    [self.filtersArray addObject:sortDict];
    
    NSDictionary *generalDict = @{@"title":@"General Features", @"filters":@[@"Take-out", @"Good for Groups", @"Take Reservations"], @"type":TypeSwitch};
    [self.filtersArray addObject:generalDict];
    
    self.selectedSort = 0;
    self.selectedDistance = 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *section = self.filtersArray[indexPath.section];
    NSArray *filters = self.filtersArray[indexPath.section][@"filters"];

    UITableViewCell *cell;
    
    if ([section[@"type"] isEqualToString:TypeSwitch]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FilterCell"];
        [(FilterCell *)cell setData: filters[indexPath.row]];
    } else if ([section[@"type"] isEqualToString:TypeDropdown]) {
        if ([section[@"title"] isEqualToString:@"Sort by"]) {
            cell = [self configureSortCell:filters atIndexPath:indexPath selected:self.selectedSort];
        } else if ([section[@"title"] isEqualToString:@"Distance"]) {
            cell = [self configureSortCell:filters atIndexPath:indexPath selected:self.selectedDistance];
        }
        
    }
    return cell;
}

- (FilterDropdownCell *)configureSortCell : (NSArray *)filters atIndexPath:(NSIndexPath *)indexPath selected:(NSInteger)index{
    FilterDropdownCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FilterDropdownCell"];
    if (![self.expandedSections containsIndex:indexPath.section]) {
        [cell setData: filters[index]];
        [cell.iconLabel setImage:[UIImage imageNamed:@"dropdown"]];
    } else {
        [cell setData: filters[indexPath.row]];
        NSString *icon = indexPath.row == index ? @"Checkbox_selected" : @"Checkbox";
        [cell.iconLabel setImage:[UIImage imageNamed:icon]];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *section = self.filtersArray[indexPath.section];
    if ([section[@"type"] isEqualToString:TypeDropdown]) {
        if ([self.expandedSections containsIndex:indexPath.section]) {
            [self.expandedSections removeIndex:indexPath.section];
            if ([section[@"title"] isEqualToString:@"Sort by"]) {
                self.selectedSort = indexPath.row;
            } else if ([section[@"title"] isEqualToString:@"Distance"]) {
                self.selectedDistance = indexPath.row;
            }
        } else {
            [self.expandedSections addIndex:indexPath.section];
        }
        [tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dict =self.filtersArray[section];
    NSArray *filters = dict[@"filters"];
    if ([dict[@"type"] isEqualToString:TypeDropdown]) {
        if (![self.expandedSections containsIndex:section]) {
            return 1;
        }
    }
    return filters.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = self.filtersArray[section][@"title"];
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.filtersArray.count;
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
