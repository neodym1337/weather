//
//  WXClient.h
//  SimpleWeather
//
//  Created by Johan Hosk on 23/05/15.
//  Copyright (c) 2015 Johan Hosk. All rights reserved.
//


@import Foundation;
@import CoreLocation;
#import "Mantle.h"
#import "WXCondition.h"
#import "WXDailyForecast.h"

@interface WXClient : NSObject


typedef void(^jsonFetchCompletion)(id json, NSError *error);
typedef void(^currentConditionsCompletion)(WXCondition *condition, NSError *error);
typedef void(^hourlyForecastCompletion)(NSArray *conditionArray, NSError *error);
typedef void(^dailyForecastCompletion)(NSArray *conditionArray, NSError *error);

typedef void(^geoPhotoCompletion)(NSString *url, NSError *error);

-(void)fetchJSONFromURL:(NSURL *)url withBlock:(jsonFetchCompletion)completion;
-(void)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate withBlock:(currentConditionsCompletion)completion;
-(void)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate withBlock:(hourlyForecastCompletion)completion;
-(void)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate withBlock:(dailyForecastCompletion)completion;

-(void)fetchGeoPhotos:(CLLocationCoordinate2D)coordinate withBlock:(geoPhotoCompletion)completion;
/*

- (RACSignal *)fetchJSONFromURL:(NSURL *)url;
- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate;
*/


@end
