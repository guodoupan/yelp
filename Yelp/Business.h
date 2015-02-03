//
//  Business.h
//  Yelp
//
//  Created by Doupan Guo on 1/31/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusinessAnnotation.h"

@interface Business : NSObject

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *ratingImageUrl;
@property (nonatomic, assign) NSInteger numReviews;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *categories;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, assign) BOOL isClosed;

+ (NSArray *)businessesWithDictionary: (NSArray *)dictionaries;
- (BusinessAnnotation *)asAnnotation;
@end
