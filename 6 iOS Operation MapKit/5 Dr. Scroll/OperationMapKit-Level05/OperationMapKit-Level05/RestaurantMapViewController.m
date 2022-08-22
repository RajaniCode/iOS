#import "RestaurantMapViewController.h"
#import "MapAnnotation.h"
#import "AFJSONRequestOperation.h"

@implementation RestaurantMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.theMap = [[MKMapView alloc] init];
    self.theMap.frame = CGRectMake(0, 0, 320, 300);
    self.theMap.delegate = self;
    self.theMap.scrollEnabled = YES;
    self.theMap.zoomEnabled = NO;
    
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(28.539894, -81.381397);
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
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://operationmapkit.codeschool.com/getAllRestaurants.json"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            self.restaurants = JSON;
            [self showRestaurantsAndCenter:NO];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
                    NSError *error, id JSON) {
            NSLog(@"NSError: %@",error.localizedDescription);
        }];
    
    [operation start];
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [self.theMap setCenterCoordinate:[[view annotation] coordinate] animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    MKAnnotationView *view = [self.theMap dequeueReusableAnnotationViewWithIdentifier:@"annoView"];
    if(!view) {
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annoView"];
    }
    
    MapAnnotation *singleAnnotation = annotation;
    
    if([singleAnnotation.cost isEqualToString:@"cheap"]) {
        view.image = [UIImage imageNamed:@"cheap.png"];
    } else if([singleAnnotation.cost isEqualToString:@"expensive"]) {
        view.image = [UIImage imageNamed:@"expensive.png"];
    }
    
    view.canShowCallout = YES;
    
    return view;
}

- (void)showRestaurantsAndCenter:(BOOL)shouldCenter
{
    for(NSDictionary *restaurant in self.restaurants) {
        CLLocationCoordinate2D annotationCoordinate = CLLocationCoordinate2DMake([restaurant[@"lat"] doubleValue], [restaurant[@"lng"] doubleValue]);
        
        MapAnnotation *annotation = [[MapAnnotation alloc] init];
        annotation.coordinate = annotationCoordinate;
        annotation.title = restaurant[@"name"];
        annotation.subtitle = restaurant[@"contact"];
        annotation.cost = restaurant[@"cost"];
        
        [self.theMap addAnnotation:annotation];
    }
    
    if(shouldCenter) {
        NSMutableArray *lats = [[NSMutableArray alloc] init];
        NSMutableArray *lngs = [[NSMutableArray alloc] init];
        
        for(NSDictionary *restaurant in self.restaurants) {
            [lats addObject:[NSNumber numberWithDouble:[restaurant[@"lat"] doubleValue]]];
            [lngs addObject:[NSNumber numberWithDouble:[restaurant[@"lng"] doubleValue]]];
        }
        
        [lats sortUsingSelector:@selector(compare:)];
        [lngs sortUsingSelector:@selector(compare:)];
        
        double smallestLat = [lats[0] doubleValue];
        double smallestLng = [lngs[0] doubleValue];
        double biggestLat  = [[lats lastObject] doubleValue];
        double biggestLng  = [[lngs lastObject] doubleValue];
        
        CLLocationCoordinate2D annotationsCenter = CLLocationCoordinate2DMake((biggestLat + smallestLat) / 2, (biggestLng + smallestLng) / 2);
        
        MKCoordinateSpan annotationsSpan = MKCoordinateSpanMake((biggestLat - smallestLat), (biggestLng - smallestLng));
        
        MKCoordinateRegion region = MKCoordinateRegionMake(annotationsCenter, annotationsSpan);
        
        [self.theMap setRegion:region];
    }
}

@end
