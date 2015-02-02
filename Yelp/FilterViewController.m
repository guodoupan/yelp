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
static int Sort[] = {0, 1, 2};
static int radius[] = {0, 483, 1610, 8047, 32187};

@interface FilterViewController () <UITableViewDataSource, UITableViewDelegate, FilterCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *filtersArray;
@property (nonatomic, strong) NSMutableIndexSet *expandedSections;
@property (nonatomic, strong) NSMutableArray *selectedFilters;
@property (nonatomic, strong) NSArray *categories;

@property (nonatomic, assign) NSInteger selectedSort;
@property (nonatomic, assign) NSInteger selectedDistance;
@property (nonatomic, assign) BOOL deal;

- (void)onCancel;
- (void)onSearch;
- (void)initFilters;
- (NSArray *)getRestaurantCategories;
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
    if (!self.selectedFilters) {
        self.selectedFilters = [[NSMutableArray alloc] init];
    }

    if (!self.categories) {
        self.categories = [self getRestaurantCategories];
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
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.selectedSort > 0) {
        [dict setObject:@(Sort[self.selectedSort]) forKey:@"sort"];
    }
    if (self.selectedDistance > 0) {
        [dict setObject:@(radius[self.selectedDistance]) forKey:@"radius_filter"];
    }
    if (self.deal) {
        [dict setObject:@(self.deal) forKey:@"deals_filter"];
    }
    if (self.selectedFilters.count > 0) {
        NSString *categories = [self.selectedFilters componentsJoinedByString:@","];
        [dict setObject:categories forKey:@"category_filter"];
    }
    [self.delegate filtersViewController:self didChangeFilters:dict];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initFilters {
    self.filtersArray = [[NSMutableArray alloc] init];

    NSDictionary *popularDict = @{@"title":@"Most Popular", @"filters":@[@{@"name": @"Offering a Deal"}], @"type":TypeSwitch};
    [self.filtersArray addObject:popularDict];
    
    NSDictionary *distanceDict = @{@"title":@"Distance", @"filters":@[@"Auto", @"0.3 miles", @"1 mile", @"5 miles", @"20 miles"], @"type":TypeDropdown, @"select":@"0"};
    [self.filtersArray addObject:distanceDict];
    
    NSDictionary *sortDict = @{@"title":@"Sort by", @"filters":@[@"Best Match", @"Distance", @"Rating", @"Most Reviewed"], @"type":TypeDropdown, @"select":@"0"};
    [self.filtersArray addObject:sortDict];
    
    /*
    NSDictionary *generalDict = @{@"title":@"General Features", @"filters":@[@"Take-out", @"Good for Groups", @"Take Reservations"], @"type":TypeSwitch};
    [self.filtersArray addObject:generalDict];
    */
    NSDictionary *categoryDict = @{@"title":@"Category", @"filters":self.categories, @"type":TypeSwitch};
    [self.filtersArray addObject:categoryDict];
    self.selectedSort = 0;
    self.selectedDistance = 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *section = self.filtersArray[indexPath.section];
    NSArray *filters = self.filtersArray[indexPath.section][@"filters"];

    UITableViewCell *cell;
    
    if ([section[@"type"] isEqualToString:TypeSwitch]) {
        FilterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilterCell"];
        cell.nameLabel.text = filters[indexPath.row][@"name"];
        cell.delegate = self;
        if ([filters[0][@"name"] isEqualToString:@"Offering a Deal"]) {
            [cell setOn:self.deal];
        } else {
            [cell setOn:[self.selectedFilters containsObject:filters[indexPath.row][@"code"]]];
        }
        return cell;
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

- (void)filterCell:(FilterCell *)cell didChangeValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *dict =self.filtersArray[indexPath.section];
    NSArray *filters = dict[@"filters"];
    if ([filters[0][@"name"] isEqualToString:@"Offering a Deal"]) {
        self.deal = value;
    } else {
        if (value) {
            [self.selectedFilters addObject:filters[indexPath.row][@"code"]];
        } else {
            [self.selectedFilters removeObject:filters[indexPath.row][@"code"]];
        }
    }
    NSLog(@"%@", self.selectedFilters);
}

- (NSArray *) getRestaurantCategories {
    NSArray *categories = @[@{@"name" : @"Afghan", @"code": @"afghani" },
                            @{@"name" : @"African", @"code": @"african" },
                            @{@"name" : @"American, New", @"code": @"newamerican" },
                            @{@"name" : @"American, Traditional", @"code": @"tradamerican" },
                            @{@"name" : @"Arabian", @"code": @"arabian" },
                            @{@"name" : @"Argentine", @"code": @"argentine" },
                            @{@"name" : @"Armenian", @"code": @"armenian" },
                            @{@"name" : @"Asian Fusion", @"code": @"asianfusion" },
                            @{@"name" : @"Asturian", @"code": @"asturian" },
                            @{@"name" : @"Australian", @"code": @"australian" },
                            @{@"name" : @"Austrian", @"code": @"austrian" },
                            @{@"name" : @"Baguettes", @"code": @"baguettes" },
                            @{@"name" : @"Bangladeshi", @"code": @"bangladeshi" },
                            @{@"name" : @"Barbeque", @"code": @"bbq" },
                            @{@"name" : @"Basque", @"code": @"basque" },
                            @{@"name" : @"Bavarian", @"code": @"bavarian" },
                            @{@"name" : @"Beer Garden", @"code": @"beergarden" },
                            @{@"name" : @"Beer Hall", @"code": @"beerhall" },
                            @{@"name" : @"Beisl", @"code": @"beisl" },
                            @{@"name" : @"Belgian", @"code": @"belgian" },
                            @{@"name" : @"Bistros", @"code": @"bistros" },
                            @{@"name" : @"Black Sea", @"code": @"blacksea" },
                            @{@"name" : @"Brasseries", @"code": @"brasseries" },
                            @{@"name" : @"Brazilian", @"code": @"brazilian" },
                            @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
                            @{@"name" : @"British", @"code": @"british" },
                            @{@"name" : @"Buffets", @"code": @"buffets" },
                            @{@"name" : @"Bulgarian", @"code": @"bulgarian" },
                            @{@"name" : @"Burgers", @"code": @"burgers" },
                            @{@"name" : @"Burmese", @"code": @"burmese" },
                            @{@"name" : @"Cafes", @"code": @"cafes" },
                            @{@"name" : @"Cafeteria", @"code": @"cafeteria" },
                            @{@"name" : @"Cajun/Creole", @"code": @"cajun" },
                            @{@"name" : @"Cambodian", @"code": @"cambodian" },
                            @{@"name" : @"Canadian", @"code": @"New)" },
                            @{@"name" : @"Canteen", @"code": @"canteen" },
                            @{@"name" : @"Caribbean", @"code": @"caribbean" },
                            @{@"name" : @"Catalan", @"code": @"catalan" },
                            @{@"name" : @"Chech", @"code": @"chech" },
                            @{@"name" : @"Cheesesteaks", @"code": @"cheesesteaks" },
                            @{@"name" : @"Chicken Shop", @"code": @"chickenshop" },
                            @{@"name" : @"Chicken Wings", @"code": @"chicken_wings" },
                            @{@"name" : @"Chilean", @"code": @"chilean" },
                            @{@"name" : @"Chinese", @"code": @"chinese" },
                            @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
                            @{@"name" : @"Corsican", @"code": @"corsican" },
                            @{@"name" : @"Creperies", @"code": @"creperies" },
                            @{@"name" : @"Cuban", @"code": @"cuban" },
                            @{@"name" : @"Curry Sausage", @"code": @"currysausage" },
                            @{@"name" : @"Cypriot", @"code": @"cypriot" },
                            @{@"name" : @"Czech", @"code": @"czech" },
                            @{@"name" : @"Czech/Slovakian", @"code": @"czechslovakian" },
                            @{@"name" : @"Danish", @"code": @"danish" },
                            @{@"name" : @"Delis", @"code": @"delis" },
                            @{@"name" : @"Diners", @"code": @"diners" },
                            @{@"name" : @"Dumplings", @"code": @"dumplings" },
                            @{@"name" : @"Eastern European", @"code": @"eastern_european" },
                            @{@"name" : @"Ethiopian", @"code": @"ethiopian" },
                            @{@"name" : @"Fast Food", @"code": @"hotdogs" },
                            @{@"name" : @"Filipino", @"code": @"filipino" },
                            @{@"name" : @"Fish & Chips", @"code": @"fishnchips" },
                            @{@"name" : @"Fondue", @"code": @"fondue" },
                            @{@"name" : @"Food Court", @"code": @"food_court" },
                            @{@"name" : @"Food Stands", @"code": @"foodstands" },
                            @{@"name" : @"French", @"code": @"french" },
                            @{@"name" : @"French Southwest", @"code": @"sud_ouest" },
                            @{@"name" : @"Galician", @"code": @"galician" },
                            @{@"name" : @"Gastropubs", @"code": @"gastropubs" },
                            @{@"name" : @"Georgian", @"code": @"georgian" },
                            @{@"name" : @"German", @"code": @"german" },
                            @{@"name" : @"Giblets", @"code": @"giblets" },
                            @{@"name" : @"Gluten-Free", @"code": @"gluten_free" },
                            @{@"name" : @"Greek", @"code": @"greek" },
                            @{@"name" : @"Halal", @"code": @"halal" },
                            @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
                            @{@"name" : @"Heuriger", @"code": @"heuriger" },
                            @{@"name" : @"Himalayan/Nepalese", @"code": @"himalayan" },
                            @{@"name" : @"Hong Kong Style Cafe", @"code": @"hkcafe" },
                            @{@"name" : @"Hot Dogs", @"code": @"hotdog" },
                            @{@"name" : @"Hot Pot", @"code": @"hotpot" },
                            @{@"name" : @"Hungarian", @"code": @"hungarian" },
                            @{@"name" : @"Iberian", @"code": @"iberian" },
                            @{@"name" : @"Indian", @"code": @"indpak" },
                            @{@"name" : @"Indonesian", @"code": @"indonesian" },
                            @{@"name" : @"International", @"code": @"international" },
                            @{@"name" : @"Irish", @"code": @"irish" },
                            @{@"name" : @"Island Pub", @"code": @"island_pub" },
                            @{@"name" : @"Israeli", @"code": @"israeli" },
                            @{@"name" : @"Italian", @"code": @"italian" },
                            @{@"name" : @"Japanese", @"code": @"japanese" },
                            @{@"name" : @"Jewish", @"code": @"jewish" },
                            @{@"name" : @"Kebab", @"code": @"kebab" },
                            @{@"name" : @"Korean", @"code": @"korean" },
                            @{@"name" : @"Kosher", @"code": @"kosher" },
                            @{@"name" : @"Kurdish", @"code": @"kurdish" },
                            @{@"name" : @"Laos", @"code": @"laos" },
                            @{@"name" : @"Laotian", @"code": @"laotian" },
                            @{@"name" : @"Latin American", @"code": @"latin" },
                            @{@"name" : @"Live/Raw Food", @"code": @"raw_food" },
                            @{@"name" : @"Lyonnais", @"code": @"lyonnais" },
                            @{@"name" : @"Malaysian", @"code": @"malaysian" },
                            @{@"name" : @"Meatballs", @"code": @"meatballs" },
                            @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
                            @{@"name" : @"Mexican", @"code": @"mexican" },
                            @{@"name" : @"Middle Eastern", @"code": @"mideastern" },
                            @{@"name" : @"Milk Bars", @"code": @"milkbars" },
                            @{@"name" : @"Modern Australian", @"code": @"modern_australian" },
                            @{@"name" : @"Modern European", @"code": @"modern_european" },
                            @{@"name" : @"Mongolian", @"code": @"mongolian" },
                            @{@"name" : @"Moroccan", @"code": @"moroccan" },
                            @{@"name" : @"New Zealand", @"code": @"newzealand" },
                            @{@"name" : @"Night Food", @"code": @"nightfood" },
                            @{@"name" : @"Norcinerie", @"code": @"norcinerie" },
                            @{@"name" : @"Open Sandwiches", @"code": @"opensandwiches" },
                            @{@"name" : @"Oriental", @"code": @"oriental" },
                            @{@"name" : @"Pakistani", @"code": @"pakistani" },
                            @{@"name" : @"Parent Cafes", @"code": @"eltern_cafes" },
                            @{@"name" : @"Parma", @"code": @"parma" },
                            @{@"name" : @"Persian/Iranian", @"code": @"persian" },
                            @{@"name" : @"Peruvian", @"code": @"peruvian" },
                            @{@"name" : @"Pita", @"code": @"pita" },
                            @{@"name" : @"Pizza", @"code": @"pizza" },
                            @{@"name" : @"Polish", @"code": @"polish" },
                            @{@"name" : @"Portuguese", @"code": @"portuguese" },
                            @{@"name" : @"Potatoes", @"code": @"potatoes" },
                            @{@"name" : @"Poutineries", @"code": @"poutineries" },
                            @{@"name" : @"Pub Food", @"code": @"pubfood" },
                            @{@"name" : @"Rice", @"code": @"riceshop" },
                            @{@"name" : @"Romanian", @"code": @"romanian" },
                            @{@"name" : @"Rotisserie Chicken", @"code": @"rotisserie_chicken" },
                            @{@"name" : @"Rumanian", @"code": @"rumanian" },
                            @{@"name" : @"Russian", @"code": @"russian" },
                            @{@"name" : @"Salad", @"code": @"salad" },
                            @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
                            @{@"name" : @"Scandinavian", @"code": @"scandinavian" },
                            @{@"name" : @"Scottish", @"code": @"scottish" },
                            @{@"name" : @"Seafood", @"code": @"seafood" },
                            @{@"name" : @"Serbo Croatian", @"code": @"serbocroatian" },
                            @{@"name" : @"Signature Cuisine", @"code": @"signature_cuisine" },
                            @{@"name" : @"Singaporean", @"code": @"singaporean" },
                            @{@"name" : @"Slovakian", @"code": @"slovakian" },
                            @{@"name" : @"Soul Food", @"code": @"soulfood" },
                            @{@"name" : @"Soup", @"code": @"soup" },
                            @{@"name" : @"Southern", @"code": @"southern" },
                            @{@"name" : @"Spanish", @"code": @"spanish" },
                            @{@"name" : @"Steakhouses", @"code": @"steak" },
                            @{@"name" : @"Sushi Bars", @"code": @"sushi" },
                            @{@"name" : @"Swabian", @"code": @"swabian" },
                            @{@"name" : @"Swedish", @"code": @"swedish" },
                            @{@"name" : @"Swiss Food", @"code": @"swissfood" },
                            @{@"name" : @"Tabernas", @"code": @"tabernas" },
                            @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
                            @{@"name" : @"Tapas Bars", @"code": @"tapas" },
                            @{@"name" : @"Tapas/Small Plates", @"code": @"tapasmallplates" },
                            @{@"name" : @"Tex-Mex", @"code": @"tex-mex" },
                            @{@"name" : @"Thai", @"code": @"thai" },
                            @{@"name" : @"Traditional Norwegian", @"code": @"norwegian" },
                            @{@"name" : @"Traditional Swedish", @"code": @"traditional_swedish" },
                            @{@"name" : @"Trattorie", @"code": @"trattorie" },
                            @{@"name" : @"Turkish", @"code": @"turkish" },
                            @{@"name" : @"Ukrainian", @"code": @"ukrainian" },
                            @{@"name" : @"Uzbek", @"code": @"uzbek" },
                            @{@"name" : @"Vegan", @"code": @"vegan" },
                            @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
                            @{@"name" : @"Venison", @"code": @"venison" },
                            @{@"name" : @"Vietnamese", @"code": @"vietnamese" },
                            @{@"name" : @"Wok", @"code": @"wok" },
                            @{@"name" : @"Wraps", @"code": @"wraps" },
                            @{@"name" : @"Yugoslav", @"code": @"yugoslav" }];
    
    
    return categories;
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
