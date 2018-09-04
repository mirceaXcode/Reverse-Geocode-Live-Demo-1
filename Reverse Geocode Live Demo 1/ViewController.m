//
//  ViewController.m
//  Reverse Geocode Live Demo 1
//
//  Created by Mircea Popescu on 9/4/18.
//  Copyright © 2018 Mircea Popescu. All rights reserved.
//

#import "ViewController.h"
#import "MapKit/MapKit.h"
#import "CoreLocation/CoreLocation.h"


@interface ViewController () <MKMapViewDelegate>

@property (strong, nonatomic) CLGeocoder *geocoder;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *reverseGeocodeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pinIcon;

@property (assign, nonatomic) BOOL lookUp;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.geocoder = [[CLGeocoder alloc] init];
    self.reverseGeocodeLabel.text = nil;
    self.reverseGeocodeLabel.alpha = 0.5;
    self.lookUp = NO;
    
}

-(void) executeTheLookUp {
    if(self.lookUp == NO){
        self.lookUp = YES;
        CLLocationCoordinate2D coord = [self locationAtCenterOfMapView];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
        [self startReverseGeocodeLocation:loc];
    }
    
}

-(void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [self executeTheLookUp];
}

#pragma mark - Private

-(CLLocationCoordinate2D) locationAtCenterOfMapView {
    // Calculate center of the space in the ImageView coord space
    CGPoint centerOfPin = CGPointMake(CGRectGetMidX(self.pinIcon.bounds), CGRectGetMidY(self.pinIcon.bounds));
    // Convert it into our mapView coord space
    return [self.mapView convertPoint:centerOfPin toCoordinateFromView:self.pinIcon];
}

-(void) startReverseGeocodeLocation: (CLLocation *) location {
    
    [_geocoder reverseGeocodeLocation:location completionHandler:
     ^(NSArray *placemarks, NSError *error){
         if (error){
             UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"There was a problem reverse geocoding" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
             [self presentViewController:ac animated:YES completion:nil];
             return;
         }
         // Grab some interesting bits of CLPlaceMark and show it
         // But no duplicates!
         NSMutableSet *mappedPlaceDescs = [NSMutableSet new];
         for (CLPlacemark *p in placemarks){
             if (p.name != nil)
                 [mappedPlaceDescs addObject:p.name];
             if (p.administrativeArea != nil)
                 [mappedPlaceDescs addObject:p.administrativeArea];
             if (p.country != nil)
                 [mappedPlaceDescs addObject:p.country];
             [mappedPlaceDescs addObjectsFromArray:p.areasOfInterest];
         }
         self.reverseGeocodeLabel.text =[[ mappedPlaceDescs allObjects] componentsJoinedByString:@"\n"];
         self.reverseGeocodeLabel.alpha = 1.0;
         self.lookUp = NO;
     }];
}

@end
