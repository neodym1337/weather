//
//  WXDailyForecast.m
//  SimpleWeather
//
//  Created by Johan Hosk on 23/05/15.
//  Copyright (c) 2015 Johan Hosk. All rights reserved.
//

#import "WXDailyForecast.h"

@implementation WXDailyForecast

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  // 1
  NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
  // 2
  paths[@"tempHigh"] = @"temp.max";
  paths[@"tempLow"] = @"temp.min";
  // 3
  return paths;
}


@end
