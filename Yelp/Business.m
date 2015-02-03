//
//  Business.m
//  Yelp
//
//  Created by Doupan Guo on 1/31/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "Business.h"

@implementation Business

- (id)initWithDictionary: (NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        NSArray *categories = dictionary[@"categories"];
        NSMutableArray *categoryNames = [NSMutableArray array];
        [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [categoryNames addObject:obj[0]];
        }];
        
        self.categories = [categoryNames componentsJoinedByString:@", "];
        self.name = dictionary[@"name"];
        self.imageUrl = dictionary[@"image_url"];
        
        NSArray *addresses = [dictionary valueForKeyPath:@"location.address"];
        NSString *street = addresses.count > 0 ? [NSString stringWithFormat:@"%@, ", addresses[0]] : @"";
        NSArray *neighborhoods = [dictionary valueForKeyPath:@"location.neighborhoods"];
        NSString *neighborhood = neighborhoods.count > 0 ? neighborhoods[0] : @"";
        self.address = [NSString stringWithFormat:@"%@%@", street, neighborhood];
        self.latitude = [dictionary valueForKeyPath:@"location.coordinate.latitude"];
        self.longitude = [dictionary valueForKeyPath:@"location.coordinate.longitude"];
        self.isClosed = [[dictionary valueForKey:@"is_closed"] boolValue];
        
        self.numReviews = [dictionary[@"review_count"] integerValue];
        self.ratingImageUrl = dictionary[@"rating_img_url"];
        float milesPerMeter = 0.000621371;
        self.distance = [dictionary[@"distance"] integerValue] * milesPerMeter;
         
         
    }
    return self;
}

+ (NSArray *)businessesWithDictionary: (NSArray *)dictionaries {
    NSMutableArray *businesses = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        Business *business = [[Business alloc] initWithDictionary:dictionary];

        [businesses addObject:business];
    }
    
    return businesses;
}

- (BusinessAnnotation *)asAnnotation {
    float latitude = [self.latitude floatValue];
    float longitude = [self.longitude floatValue];
    BusinessAnnotation *anno = [[BusinessAnnotation alloc] initWithLocation:CLLocationCoordinate2DMake(latitude, longitude)];
    [anno setIsClosed:self.isClosed];
    [anno setRating_img_url:[NSURL URLWithString:self.ratingImageUrl]];
    [anno setReviewCount:self.numReviews];
    [anno setTitle:self.name];
    return anno;
}
@end
