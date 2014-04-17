//
//  collectionRemovalsViewController.m
//  Hot Wheels 2.0
//
//  Created by Mike on 12/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "collectionRemovalsViewController.h"
#import "detailsViewController.h"
#import "CarManager.h"
#import "UICarGridView.h"
#import "HotWheels2API.h"
#import "ImageBank.h"
#import "UserManager.h"

@interface collectionRemovalsViewController () <UICarGridViewDelegate>
@property(nonatomic, strong) IBOutlet UIBarButtonItem *refreshButton;
@property(nonatomic, strong) IBOutlet UICarGridView   *carGridView;
@property(nonatomic, strong) IBOutlet UILabel         *emptyCollectionRemovalsLabel;

@property(nonatomic, strong) UIBarButtonItem         *activityButton;
@property(nonatomic, strong) UIActivityIndicatorView *activityView;

@property bool collectionRemovalsRequesting;

@property(nonatomic, weak) CarWrapper *selectedCarWrapper;
@end


@implementation collectionRemovalsViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// create the activity button for the navigation bar
	self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	[self.activityView startAnimating];
	
	self.activityButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityView];
	
	// setup car grid
	self.carGridView.carGridViewDelegate = self;
	
	// get the collection
	[self refreshCollectionRemovals];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


// refresh collection on view
//- (void)viewWillAppear:(BOOL)animated
//{
//	[self refreshCollectionRemovals];
//}




- (void)toggleRefreshActivity:(bool) show
{
	self.navigationItem.rightBarButtonItem = show ? self.activityButton : self.refreshButton;
}




- (IBAction)refreshButtonPressed:(id) sender
{
	[self refreshCollectionRemovals];
}



- (void)refreshCollectionRemovals
{
	// make sure we are not already refreshing
	if (self.collectionRemovalsRequesting)
		return;
	
	// we are now requesting, disable the refresh button and show the activity indicator
	self.collectionRemovalsRequesting = true;
	self.refreshButton.enabled = false;
	[self toggleRefreshActivity:true];
	
	// make the request
	[HotWheels2API getCollectionRemovals:[UserManager getLoggedInUserID] completionHandler:^(HotWheels2APIError *error, NSMutableArray *cars)
	{
		self.collectionRemovalsRequesting = false;
		
		// enable the refresh button and hide the activity indicator
		dispatch_async(dispatch_get_main_queue(), ^
		{
			self.refreshButton.enabled = true;
			[self toggleRefreshActivity:false];
			
			if (error)
			{
				[[error createAlert:@"Unable to get Collection"] show];
				return;
			}
			
			// update screen
			[self.carGridView setCars:cars];
			
			// show the "no removals" label if did not get any results
			self.emptyCollectionRemovalsLabel.hidden = cars.count > 0;
		});
	}];
}




- (void)carWrapperSelected:(CarWrapper *)carWrapper
{
	self.selectedCarWrapper = carWrapper;
	[self performSegueWithIdentifier:@"collectionRemovalsToDetails" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	// set the car the detail view should display
	detailsViewController *controller = (detailsViewController *)segue.destinationViewController;
	controller.carWrapper = self.selectedCarWrapper;
}
@end
