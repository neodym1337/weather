//
//  WXManager.m
//  SimpleWeather
//
//  Created by Johan Hosk on 23/05/15.
//  Copyright (c) 2015 Johan Hosk. All rights reserved.
//

#import "WXManager.h"

#import "WXClient.h"
#import <TSMessages/TSMessage.h>

@interface WXManager ()

// 1
@property (nonatomic, strong, readwrite) WXCondition *currentCondition;
@property (nonatomic, strong, readwrite) CLLocation *currentLocation;
@property (nonatomic, strong, readwrite) NSArray *hourlyForecast;
@property (nonatomic, strong, readwrite) NSArray *dailyForecast;

// 2
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, assign) BOOL isUpdating;
@property (nonatomic, strong) WXClient *client;

@property (nonatomic, copy) locationStatusHandler locationStatusHandler;

@end

@implementation WXManager

+ (instancetype)sharedManager {
  static id _sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedManager = [[self alloc] init];
  });
  
  return _sharedManager;
}

- (id)init {
  if (self = [super init]) {
    // 1
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    // 2
    _client = [[WXClient alloc] init];
    
    self.hourlyForecast = [[NSArray alloc] init];
    self.dailyForecast = [[NSArray alloc] init];
    
  }
  return self;
}



-(void)findCurrentLocationWithBlock:(locationStatusHandler)locationStatusHandler {
  NSLog(@"Updating location");
  self.locationStatusHandler = locationStatusHandler;
  self.isFirstUpdate = YES;
  [self.locationManager requestWhenInUseAuthorization];
  //[self.locationManager startUpdatingLocation];
  self.isUpdating = YES;
  
}

-(void)updateCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate withBlock:(currentConditionsCompletion)completion {
  [self.client fetchCurrentConditionsForLocation:coordinate withBlock:^(WXCondition *condition, NSError *error) {
    if (!error) {
      self.currentCondition = condition;
      completion(condition, nil);
    }else {
      completion(nil, error);
    }
  }];
}

-(void)updateDailyForecastForLocation:(CLLocationCoordinate2D)coordinate withBlock:(dailyForecastCompletion)completion {
  [self.client fetchDailyForecastForLocation:coordinate withBlock:^(NSArray *conditionArray, NSError *error) {
    if (!error) {
      self.dailyForecast = conditionArray;
      completion(conditionArray, nil);
    }else {
      completion(nil, error);
    }
  }];
}

-(void)updateHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate withBlock:(hourlyForecastCompletion)completion {
  [self.client fetchHourlyForecastForLocation:coordinate withBlock:^(NSArray *conditionArray, NSError *error) {
    if (!error) {
      self.hourlyForecast = conditionArray;
      completion(conditionArray, nil);
    }else {
      completion(nil, error);
    }
  }];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  
  
  
  
  switch (status) {
      /*
    case kCLAuthorizationStatusAuthorized:
      NSLog(@"kCLAuthorizationStatusAuthorized");
      // Re-enable the post button if it was disabled before.
      self.navigationItem.rightBarButtonItem.enabled = YES;
      [locationManager startUpdatingLocation];
      break;
       */
    case kCLAuthorizationStatusDenied:
      //NSLog(@"kCLAuthorizationStatusDenied");
      
      
      if (self.locationStatusHandler) {
        self.locationStatusHandler(nil, @"kCLAuthorizationStatusDenied");
      }
      
      /*
    {{
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Anywall can’t access your current location.\n\nTo view nearby posts or create a post at your current location, turn on access for Anywall to your location in the Settings app under Location Services." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
      [alertView show];
      // Disable the post button.
      self.navigationItem.rightBarButtonItem.enabled = NO;
    }}
       */
      break;
    case kCLAuthorizationStatusNotDetermined:
      //NSLog(@"kCLAuthorizationStatusNotDetermined");
      if (self.locationStatusHandler) {
        self.locationStatusHandler(nil, @"kCLAuthorizationStatusNotDetermined");
      }
      break;
    case kCLAuthorizationStatusRestricted:
      //NSLog(@"kCLAuthorizationStatusRestricted");
      if (self.locationStatusHandler) {
        self.locationStatusHandler(nil, @"kCLAuthorizationStatusRestricted");
      }
      break;
    case kCLAuthorizationStatusAuthorizedAlways:
    case kCLAuthorizationStatusAuthorizedWhenInUse:
      NSLog(@"Authorized kCLAuthorizationStatusAuthorizedWhenInUse");
      
       [self.locationManager startUpdatingLocation];
      break;
    default:
      break;
  }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  // 1
  if (self.isFirstUpdate) {
    self.isFirstUpdate = NO;
    //return;
  }
  
  if (self.isUpdating) {
    self.isUpdating = NO;
  }else {
    return;
  }
  
  // 48.121259, long: 11.562163
  
  CLLocation *location = [locations lastObject];
  
  // 2
  if (location.horizontalAccuracy > 0) {
    // 3
    self.currentLocation = location;

    NSLog(@"Found location coordinate, lat: %f, long: %f", location.coordinate.latitude, location.coordinate.longitude);
    
    if (self.locationStatusHandler) {
      [self.locationManager stopUpdatingLocation];
      self.locationStatusHandler(location, nil);
    }
    [self.locationManager stopUpdatingLocation];
  }
}


@end
