//
//  WXCondition.m
//  SimpleWeather
//
//  Created by Johan Hosk on 23/05/15.
//  Copyright (c) 2015 Johan Hosk. All rights reserved.
//

#import "WXCondition.h"
#import "Mantle.h"

@implementation WXCondition

+ (NSDictionary *)imageMap {
  // 1
  static NSDictionary *_imageMap = nil;
  if (! _imageMap) {
    // 2
    _imageMap = @{
                  @"01d" : @"weather-clear",
                  @"02d" : @"weather-few",
                  @"03d" : @"weather-few",
                  @"04d" : @"weather-broken",
                  @"09d" : @"weather-shower",
                  @"10d" : @"weather-rain",
                  @"11d" : @"weather-tstorm",
                  @"13d" : @"weather-snow",
                  @"50d" : @"weather-mist",
                  @"01n" : @"weather-moon",
                  @"02n" : @"weather-few-night",
                  @"03n" : @"weather-few-night",
                  @"04n" : @"weather-broken",
                  @"09n" : @"weather-shower",
                  @"10n" : @"weather-rain-night",
                  @"11n" : @"weather-tstorm",
                  @"13n" : @"weather-snow",
                  @"50n" : @"weather-mist",
                  };
  }
  return _imageMap;
}

// 3
- (NSString *)imageName {
  return [WXCondition imageMap][self.icon];
}


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"date": @"dt",
           @"locationName": @"name",
           @"humidity": @"main.humidity",
           @"temperature": @"main.temp",
           @"tempHigh": @"main.temp_max",
           @"tempLow": @"main.temp_min",
           @"sunrise": @"sys.sunrise",
           @"sunset": @"sys.sunset",
           @"conditionDescription": @"weather.description",
           @"condition": @"weather.main",
           @"icon": @"weather.icon",
           @"windBearing": @"wind.deg",
           @"windSpeed": @"wind.speed"
           };
}
/*
+ (NSValueTransformer *)dateJSONTransformer {
  // 1
  return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
    return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
  } reverseBlock:^(NSDate *date) {
    return [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
  }];
}
*/


+ (NSValueTransformer *)dateJSONTransformer {
  
  
  return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
    return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
  } reverseBlock:^(NSDate *date) {
    return [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
  }];
  
  /*
  
  return [MTLValueTransformer transformerUsingForwardBlock:^(NSString * str, BOOL *success, NSError *__autoreleasing *error) {
    //NSString *str = (NSString *)value;
    return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
  } reverseBlock:^(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
    //NSDate *date = (NSDate *)value;
    return [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
  }];
   */
}

// 2
+ (NSValueTransformer *)sunriseJSONTransformer {
  return [self dateJSONTransformer];
}

+ (NSValueTransformer *)sunsetJSONTransformer {
  return [self dateJSONTransformer];
}

+ (NSValueTransformer *)conditionDescriptionJSONTransformer {
  
  return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *values) {
    //NSString *str = (NSString *)value;
    return [values firstObject];
  } reverseBlock:^(NSString *str) {
    return @[str];
  }];
  /*
  return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *values) {
    return [values firstObject];
  } reverseBlock:^(NSString *str) {
    return @[str];
  }];
   
   */
}

+ (NSValueTransformer *)conditionJSONTransformer {
  return [self conditionDescriptionJSONTransformer];
}

+ (NSValueTransformer *)iconJSONTransformer {
  return [self conditionDescriptionJSONTransformer];
}

#define MPS_TO_MPH 2.23694f

+ (NSValueTransformer *)windSpeedJSONTransformer {
  
  return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *num) {
    return @(num.floatValue*MPS_TO_MPH);
  } reverseBlock:^(NSNumber *speed) {
    return @(speed.floatValue/MPS_TO_MPH);
  }];
  /*
  return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *num) {
    return @(num.floatValue*MPS_TO_MPH);
  } reverseBlock:^(NSNumber *speed) {
    return @(speed.floatValue/MPS_TO_MPH);
  }];
   */
}




@end
