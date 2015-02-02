//
//  FilterViewController.h
//  Yelp
//
//  Created by Doupan Guo on 2/1/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterViewController;

@protocol FilterViewControllerDelegate <NSObject>

- (void)filtersViewController:(FilterViewController *) filtersViewControlller didChangeFilters:(NSDictionary *) filters;

@end

@interface FilterViewController : UIViewController

@property  (nonatomic, weak) id<FilterViewControllerDelegate> delegate;
@end
