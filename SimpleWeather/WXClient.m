//
//  WXClient.m
//  SimpleWeather
//
//  Created by Johan Hosk on 23/05/15.
//  Copyright (c) 2015 Johan Hosk. All rights reserved.
//

#import "WXClient.h"

@interface WXClient ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation WXClient

- (id)init {
  if (self = [super init]) {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:config];
  }
  return self;
}

-(void)fetchJSONFromURL:(NSURL *)url withBlock:(jsonFetchCompletion)completion {
  
  NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    if (!error) {
      NSError *jsonError = nil;
      id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
      if (!jsonError) {
        completion(json, nil);
        return;
        // 1
        //[subscriber sendNext:json];
      }else {
        // 2
        //[subscriber sendError:jsonError];
        completion(nil, jsonError);
        return;
      }
    }else {
      // 2
      //[subscriber sendError:error];
      completion(nil, error);
      return;
    }
    
    
    // 3
    //[subscriber sendCompleted];
  }];
  
  [dataTask resume];
}

-(void)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate withBlock:(currentConditionsCompletion)completion {
  
  NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=metric",coordinate.latitude, coordinate.longitude];
  NSURL *url = [NSURL URLWithString:urlString];
  
  [self fetchJSONFromURL:url  withBlock:^(id json, NSError *error) {
    
    if (error) {
      completion(nil, error);
    }
    if ([json isKindOfClass:[NSDictionary class]]) {
      NSDictionary *jsonDict = (NSDictionary *)json;
      
      
      NSError *error = nil;
      
      WXCondition *currentCondition = [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:jsonDict error:&error];
      
      if (!error) {
        completion(currentCondition, nil);
      }else {
        completion(nil, error);
      }
      
    }
  }];
}

-(void)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate withBlock:(hourlyForecastCompletion)completion {
  
  NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=metric&cnt=12",coordinate.latitude, coordinate.longitude];
  NSURL *url = [NSURL URLWithString:urlString];
  [self fetchJSONFromURL:url  withBlock:^(id json, NSError *error) {
    
    if (error) {
      completion(nil, error);
    }
    if ([json isKindOfClass:[NSDictionary class]]) {
      NSDictionary *jsonDict = (NSDictionary *)json;
      
      NSArray *list = [jsonDict valueForKey:@"list"];
      NSMutableArray *conditionArray = [NSMutableArray new];
      
      for (NSDictionary *hourlyForecastJson in list) {
        NSError *error = nil;
        WXCondition *currentCondition = [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:hourlyForecastJson error:&error];
        if (!error) {
          [conditionArray addObject:currentCondition];
        }else {
          completion(nil, error);
          return;
        }
      }
      completion(conditionArray, nil);
    /*
      if (!error) {
        completion(currentCondition, nil);
      }
     */
    }
  }];

}

-(void)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate withBlock:(dailyForecastCompletion)completion {
  NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=metric&cnt=7",coordinate.latitude, coordinate.longitude];
  NSURL *url = [NSURL URLWithString:urlString];
  [self fetchJSONFromURL:url  withBlock:^(id json, NSError *error) {
    
    if (error) {
      completion(nil, error);
    }
    if ([json isKindOfClass:[NSDictionary class]]) {
      NSDictionary *jsonDict = (NSDictionary *)json;
      
      NSArray *list = [jsonDict valueForKey:@"list"];
      NSMutableArray *conditionArray = [NSMutableArray new];
      
      for (NSDictionary *dayForecastJson in list) {
        NSError *error = nil;
        WXDailyForecast *dayCondition = [MTLJSONAdapter modelOfClass:[WXDailyForecast class] fromJSONDictionary:dayForecastJson error:&error];
        if (!error) {
          [conditionArray addObject:dayCondition];
        }else {
          completion(nil, error);
          return;
        }
      }
      completion(conditionArray, nil);
      /*
       if (!error) {
       completion(currentCondition, nil);
       }
       */
    }
  }];

}

-(void)fetchGeoPhotos:(CLLocationCoordinate2D)coordinate withBlock:(geoPhotoCompletion)completion {

  
  NSString *latitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
  NSString *longitude = [NSString stringWithFormat:@"%f", coordinate.longitude];
  
  //NSNumber *latitude = coordinate.latitude;
  //NSNumber *longitude = coordinate.longitude;
  

  
  NSString *baseURL = @"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=0c91fbe1336b3bd70ee3429dc2ea9f70&accuracy=11&geo_context=2&lat=48.121259&lon=11.562163&format=json&nojsoncallback=1&auth_token=72157653013229079-54e428b6abe59cd2&api_sig=94aeb84a35b209dd3b07ff8d10d2d38f";
  
  NSURL *url = [NSURL URLWithString:baseURL];
  
  
  [self fetchJSONFromURL:url  withBlock:^(id json, NSError *error) {
    
    if (error) {
      completion(nil, error);
    }
    if ([json isKindOfClass:[NSDictionary class]]) {
      NSDictionary *jsonDict = (NSDictionary *)json;
      
      /*
      NSError *error = nil;
      
      WXCondition *currentCondition = [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:jsonDict error:&error];
      
      if (!error) {
        completion(currentCondition, nil);
      }else {
        completion(nil, error);
      }
       */
      
    }
  }];

  

}

-(NSString *)flickrImageUrl:(NSDictionary *)jsonDict {
  /*
   https://farm1.staticflickr.com/2/1418878_1e92283336_m.jpg
   
   farm-id: 1
   server-id: 2
   photo-id: 1418878
   secret: 1e92283336
   size: m
   
   
   */
  
  return @"Hest";

}


/*

- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate {
  NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=imperial&cnt=7",coordinate.latitude, coordinate.longitude];
  NSURL *url = [NSURL URLWithString:urlString];
  
  // Use the generic fetch method and map results to convert into an array of Mantle objects
  return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
    // Build a sequence from the list of raw JSON
    RACSequence *list = [json[@"list"] rac_sequence];
    
    // Use a function to map results from JSON to Mantle objects
    return [[list map:^(NSDictionary *item) {
      return [MTLJSONAdapter modelOfClass:[WXDailyForecast class] fromJSONDictionary:item error:nil];
    }] array];
  }];
}
 */

@end
