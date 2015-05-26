//
//  ViewController.m
//  SimpleWeather
//
//  Created by Johan Hosk on 23/05/15.
//  Copyright (c) 2015 Johan Hosk. All rights reserved.
//

#import "WXViewController.h"
#import "WXManager.h"

#import <LBBlurredImage/UIImageView+LBBlurredImage.h>

@interface WXViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat screenHeight;

@property (nonatomic, strong) UILabel *temperatureLabel;
@property (nonatomic, strong) UILabel *hiloLabel;
@property (nonatomic, strong) UILabel *cityLabel;
@property (nonatomic, strong) UILabel *conditionsLabel;
@property (nonatomic, strong) UIImageView *iconView;


@property (nonatomic, strong) CLLocation *currentLocation;


@property (nonatomic, strong) NSDateFormatter *hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter *dailyFormatter;

@property (nonatomic, strong) UIActivityIndicatorView *weatherSpinner;

@property (nonatomic, strong) UIButton *geoLocationButton;
@property (nonatomic, strong) UIActivityIndicatorView *locationSpinner;

@property (nonatomic, strong) UIButton *reloadButton;


@end

@implementation WXViewController

- (id)init {
  if (self = [super init]) {
    _hourlyFormatter = [[NSDateFormatter alloc] init];
    _hourlyFormatter.dateFormat = @"h a";
    
    _dailyFormatter = [[NSDateFormatter alloc] init];
    _dailyFormatter.dateFormat = @"EEEE";
    //_shouldUpdateLocation = YES;
  }
  return self;
}


- (void)viewDidLoad {
  [super viewDidLoad];
  
  //self.view.backgroundColor = [UIColor darkGrayColor];
  
  self.weatherSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  self.weatherSpinner.hidesWhenStopped = YES;
  
  self.screenHeight = [[UIScreen mainScreen] bounds].size.height;
  
  
  UIImage *background = [UIImage imageNamed:@"bg"];
  
  self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
  self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
  [self.view addSubview:self.backgroundImageView];
  
  // 3
  self.blurredImageView = [[UIImageView alloc] init];
  self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
  self.blurredImageView.alpha = 0;
  [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
  [self.view addSubview:self.blurredImageView];
  
  // 4
  self.tableView = [[UITableView alloc] init];
  self.tableView.backgroundColor = [UIColor clearColor];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
  self.tableView.pagingEnabled = YES;
  [self.view addSubview:self.tableView];
  
  
  self.locationSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  self.locationSpinner.hidesWhenStopped = NO;
  //self.locationSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
  
  self.geoLocationButton = [UIButton new];

  //[self.geoLocationButton addTarget:self action:@selector(geolocationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  
  [self.geoLocationButton addTarget:self
                  action:@selector(geolocationButtonPressed:)
        forControlEvents:UIControlEventTouchUpInside];
  
  self.reloadButton = [UIButton new];
  
  [self.reloadButton addTarget:self
                             action:@selector(reloadButtonPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
  
  [self setupLayout];
  
  
}


-(void)setupLayout {
  // 1
  CGRect headerFrame = [UIScreen mainScreen].bounds;
  // 2
  CGFloat inset = 20;
  // 3
  CGFloat temperatureHeight = 110;
  CGFloat hiloHeight = 40;
  CGFloat iconHeight = 30;
  // 4
  CGRect hiloFrame = CGRectMake(inset,
                                headerFrame.size.height - hiloHeight,
                                headerFrame.size.width - (2 * inset),
                                hiloHeight);
  
  CGRect temperatureFrame = CGRectMake(inset,
                                       headerFrame.size.height - (temperatureHeight + hiloHeight),
                                       headerFrame.size.width - (2 * inset),
                                       temperatureHeight);
  
  CGRect iconFrame = CGRectMake(inset,
                                temperatureFrame.origin.y - iconHeight,
                                iconHeight,
                                iconHeight);
  // 5
  CGRect conditionsFrame = iconFrame;
  conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
  conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
  
  // 1
  UIView *header = [[UIView alloc] initWithFrame:headerFrame];
  header.backgroundColor = [UIColor clearColor];
  self.tableView.tableHeaderView = header;
  
  // 2
  // bottom left
  self.temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
  self.temperatureLabel.backgroundColor = [UIColor clearColor];
  self.temperatureLabel.textColor = [UIColor whiteColor];
  self.temperatureLabel.text = @"0°";
  self.temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
  [header addSubview:self.temperatureLabel];
  
  // bottom left
  self.hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
  self.hiloLabel.backgroundColor = [UIColor clearColor];
  self.hiloLabel.textColor = [UIColor whiteColor];
  self.hiloLabel.text = @"0° / 0°";
  self.hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
  [header addSubview:self.hiloLabel];
  
  // top
  self.cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 30)];
  self.cityLabel.backgroundColor = [UIColor clearColor];
  self.cityLabel.textColor = [UIColor whiteColor];
  self.cityLabel.text = @"Loading...";
  self.cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
  self.cityLabel.textAlignment = NSTextAlignmentCenter;
  [header addSubview:self.cityLabel];
  
  self.conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
  self.conditionsLabel.backgroundColor = [UIColor clearColor];
  self.conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
  self.conditionsLabel.textColor = [UIColor whiteColor];
  [header addSubview:self.conditionsLabel];
  
  // 3
  // bottom left
  self.iconView = [[UIImageView alloc] initWithFrame:iconFrame];
  self.iconView.contentMode = UIViewContentModeScaleAspectFit;
  self.iconView.backgroundColor = [UIColor clearColor];
  [header addSubview:self.iconView];
  
  
  CGRect locationButtonFrame = CGRectMake(headerFrame.size.width - inset - iconHeight, 20, 30, 30);
  
  UIImage *locationButtonImage = [[UIImage imageNamed:@"geolocationIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  
  [self.geoLocationButton setImage:locationButtonImage forState:UIControlStateNormal];
  [self.geoLocationButton setTintColor:[UIColor whiteColor]];
  self.geoLocationButton.frame = locationButtonFrame;
  
  [header addSubview:self.geoLocationButton];


  
  CGRect reloadButtonFrame = CGRectMake(inset, 20, iconHeight, iconHeight);
  self.reloadButton.frame = reloadButtonFrame;
  
  UIImage *reloadButtonImage = [[UIImage imageNamed:@"reloadIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  
  [self.reloadButton setImage:reloadButtonImage forState:UIControlStateNormal];
  [self.reloadButton setTintColor:[UIColor whiteColor]];
  
  [header addSubview:self.reloadButton];
  
  self.locationSpinner.frame = locationButtonFrame;
  [header addSubview:self.locationSpinner];
  

}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
  [self updateLocation];
}

#pragma mark - Layout

-(void)viewWillLayoutSubviews {
  self.backgroundImageView.frame = self.view.bounds;
  self.blurredImageView.frame = self.view.bounds;
  self.tableView.frame = self.view.bounds;
  self.weatherSpinner.center = self.view.center;
  

  
  //[self.view bringSubviewToFront:self.geoLocationButton];
  //[self.view bringSubviewToFront:self.locationSpinner];
}

-(void)updateLocation {
  
  self.locationSpinner.alpha = 0.0;
  [self.locationSpinner startAnimating];
  self.geoLocationButton.userInteractionEnabled = NO;
  [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
    
    self.geoLocationButton.alpha = 0.0;
    self.locationSpinner.alpha = 1.0;
  } completion:^(BOOL finished) {
    
  }];
  
  

  __block WXViewController *weakSelf = self;
  [[WXManager sharedManager] findCurrentLocationWithBlock:^(CLLocation *location, NSString *errorMessage) {
    
    
    if (weakSelf) {
      [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        weakSelf.geoLocationButton.alpha = 1.0;
        weakSelf.locationSpinner.alpha = 0.0;
      } completion:^(BOOL finished) {
        [self.locationSpinner stopAnimating];
        
        weakSelf.geoLocationButton.userInteractionEnabled = YES;
      }];
      
      if (!errorMessage) {
        [weakSelf updateCurrentConditions];
      }
    }
    
    
  }];

}

#pragma mark - Update weather

-(void)updateCurrentConditions {
  
  if (![[WXManager sharedManager] currentLocation]) {
    return;
  }
  //self.shouldUpdateLocation = NO;
  
  dispatch_async(dispatch_get_main_queue(), ^{
    self.weatherSpinner.alpha = 0.0;
    [self.weatherSpinner startAnimating];
    self.reloadButton.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
      
      self.reloadButton.alpha = 0.0;
      self.weatherSpinner.alpha = 1.0;
    } completion:^(BOOL finished) {
      
    }];

  });
  
  
  
  CLLocation *currentLocation = [[WXManager sharedManager] currentLocation];
  CLLocationCoordinate2D currentCoordinates = currentLocation.coordinate;
  
  // Use this inside blocks
  __block WXViewController *weakSelf = self;
  
  [[WXManager sharedManager] updateCurrentConditionsForLocation:currentCoordinates withBlock:^(WXCondition *condition, NSError *error) {
    
    if (weakSelf) {
    
      [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        [weakSelf.weatherSpinner stopAnimating];
        weakSelf.reloadButton.alpha = 1.0;
        weakSelf.weatherSpinner.alpha = 0.0;
      } completion:^(BOOL finished) {
          weakSelf.reloadButton.userInteractionEnabled = NO;
      }];
    }

    
    if (!error) {
      NSLog(@"Updated current condition forcecast");
      
      dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf) {
          [weakSelf configureHeader:condition];
          
          
        }
      });
      
    }else {
      NSLog(@"Error fetching current forecast: %@", error.localizedDescription);
    }
  }];
  
  [[WXManager sharedManager] updateDailyForecastForLocation:currentCoordinates withBlock:^(NSArray *conditionArray, NSError *error) {
    if (!error) {
      NSLog(@"Updated daily forcecast");
      dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf) {
          [weakSelf.tableView reloadData];
        }

      });

    }else {
      NSLog(@"Error fetching daily forecast: %@", error.localizedDescription);
    }
  }];
  
  [[WXManager sharedManager] updateHourlyForecastForLocation:currentCoordinates withBlock:^(NSArray *conditionArray, NSError *error) {
    if (!error) {
      
      NSLog(@"Updated hourly forcecast");
      dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf) {
          [weakSelf.tableView reloadData];
        }

      });

    }else {
      NSLog(@"Error fetching hourly forecast: %@", error.localizedDescription);
    }
  }];
  
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // 1
  if (section == 0) {
    return MIN([[WXManager sharedManager].hourlyForecast count], 6) + 1;
  }
  // 2
  return MIN([[WXManager sharedManager].dailyForecast count], 6) + 1;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"CellIdentifier";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  if (! cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
  }
  
  // 3
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
  cell.textLabel.textColor = [UIColor whiteColor];
  cell.detailTextLabel.textColor = [UIColor whiteColor];
  
  // TODO: Setup the cell
  
  if (indexPath.section == 0) {
    // 1
    if (indexPath.row == 0) {
      [self configureHeaderCell:cell title:@"Hourly Forecast"];
    }
    else {
      // 2
      WXCondition *weather = [WXManager sharedManager].hourlyForecast[indexPath.row - 1];
      [self configureHourlyCell:cell weather:weather];
    }
  }
  else if (indexPath.section == 1) {
    // 1
    if (indexPath.row == 0) {
      [self configureHeaderCell:cell title:@"Daily Forecast"];
    }
    else {
      // 3
      WXCondition *weather = [WXManager sharedManager].dailyForecast[indexPath.row - 1];
      [self configureDailyCell:cell weather:weather];
    }
  }
  
  return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
  return self.screenHeight / (CGFloat)cellCount;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - UIScrollViewDelegate 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  // 1
  CGFloat height = scrollView.bounds.size.height;
  CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
  // 2
  CGFloat percent = MIN(position / height, 0.85);
  // 3
  self.blurredImageView.alpha = percent;
}

#pragma mark - Configure tableview

-(void)configureHeader:(WXCondition *)weather {
  self.temperatureLabel.text = [NSString stringWithFormat:@"%.0f°C",weather.temperature.floatValue];
  self.conditionsLabel.text = [weather.condition capitalizedString];
  self.cityLabel.text = [weather.locationName capitalizedString];
  
  NSNumber *hi = weather.tempHigh;
  NSNumber *low = weather.tempLow;
  
  NSString *tempString = [NSString  stringWithFormat:@"%.0f°C / %.0f°C",hi.floatValue,low.floatValue];
  self.hiloLabel.text = tempString;
  // 4
  self.iconView.image = [UIImage imageNamed:[weather imageName]];
}

// 1
- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title {
  cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
  cell.textLabel.text = title;
  cell.detailTextLabel.text = @"";
  cell.imageView.image = nil;
  
  
}

// 2
- (void)configureHourlyCell:(UITableViewCell *)cell weather:(WXCondition *)weather {
  cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
  cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
  cell.textLabel.text = [self.hourlyFormatter stringFromDate:weather.date];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°C",weather.temperature.floatValue];
  cell.imageView.image = [UIImage imageNamed:[weather imageName]];
  cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

// 3
- (void)configureDailyCell:(UITableViewCell *)cell weather:(WXCondition *)weather {
  cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
  cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
  cell.textLabel.text = [self.dailyFormatter stringFromDate:weather.date];
  
  NSString *day = [self.dailyFormatter stringFromDate:weather.date];
  
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°C / %.0f°C",
                               weather.tempHigh.floatValue,
                               weather.tempLow.floatValue];
  cell.imageView.image = [UIImage imageNamed:[weather imageName]];
  cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - Locationbutton

/** Update device location */

- (void)geolocationButtonPressed:(id)sender {

   [self updateLocation];
}


- (void)reloadButtonPressed:(id)sender {
  [self updateCurrentConditions];
}

-(void)showError:(NSString *)errorMessage {

}


@end
