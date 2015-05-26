//
//  WXManager.h
//  SimpleWeather
//
//  Created by Johan Hosk on 23/05/15.
//  Copyright (c) 2015 Johan Hosk. All rights reserved.
//

@import Foundation;
@import CoreLocation;
//#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
// 1
#import "WXCondition.h"
#import "WXClient.h"

@interface WXManager : NSObject <CLLocationManagerDelegate>


typedef void(^locationStatusHandler)(CLLocation *location, NSString *errorMessage);
// 2
+ (instancetype)sharedManager;

// 3
@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) WXCondition *currentCondition;
@property (nonatomic, strong, readonly) NSArray *hourlyForecast;
@property (nonatomic, strong, readonly) NSArray *dailyForecast;

// 4
- (void)findCurrentLocationWithBlock:(locationStatusHandler)locationStatusHandler;


-(void)updateCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate withBlock:(currentConditionsCompletion)completion;
-(void)updateHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate withBlock:(hourlyForecastCompletion)completion;
-(void)updateDailyForecastForLocation:(CLLocationCoordinate2D)coordinate withBlock:(dailyForecastCompletion)completion;

@end
