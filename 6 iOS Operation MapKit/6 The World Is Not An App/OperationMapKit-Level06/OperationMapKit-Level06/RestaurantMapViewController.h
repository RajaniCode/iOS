#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface RestaurantMapViewController : UIViewController <MKMapViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) MKMapView *theMap;
@property (strong, nonatomic) UIButton *userCenterButton;
@property (strong, nonatomic) UILabel *userLocationLabel;
@property (strong, nonatomic) NSArray *restaurants;

@property BOOL userLocationUpdated;

@property (strong, nonatomic) UITextField *citySearchField;

- (void)centerOnUser:(id)sender;
- (void)showRestaurantsAndCenter:(BOOL)shouldCenter;

@end
