#import "RestaurantMapViewController.h"

@implementation RestaurantMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.theMap = [[MKMapView alloc] init];
    self.theMap.frame = CGRectMake(0, 0, 320, 300);
    self.theMap.delegate = self;
    self.theMap.scrollEnabled = YES;
    self.theMap.zoomEnabled = NO;
    
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(28.41871, -81.58121);
    double regionWidth = 2200;
    double regionHeight = 2500;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(centerCoordinate, regionWidth, regionHeight);
    
    [self.theMap setRegion:startRegion
                  animated:YES];
    
    self.theMap.showsUserLocation = YES;
    
    [self.view addSubview:self.theMap];
    
    self.userLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,360,280,40)];
    self.userLocationLabel.textAlignment = NSTextAlignmentCenter;
    self.userLocationLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    self.userLocationLabel.text = @"lat: lng: ";
    
    [self.view addSubview:self.userLocationLabel];
    
    self.userCenterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.userCenterButton.frame = CGRectMake(20,320,280,40);
    [self.userCenterButton setTitle:@"center on user"
                           forState:UIControlStateNormal];
    [self.userCenterButton addTarget:self
                              action:@selector(centerOnUser:)
                    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.userCenterButton];
    
}

- (void)centerOnUser:(id)sender
{
    [self.theMap setCenterCoordinate:self.theMap.userLocation.location.coordinate animated:YES];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(self.userLocationUpdated == NO) {
        [self centerOnUser:nil];
        self.userLocationUpdated = YES;
    }
    
    self.userLocationLabel.text = [NSString stringWithFormat:@"user location: %f, %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude];
}

@end
