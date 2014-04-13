//
//  collectionViewController.m
//  Hot Wheels 2.0
//
//  Created by Mike on 12/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "collectionViewController.h"
#import "detailsViewController.h"
#import "CarManager.h"
#import "UICarGridView.h"
#import "HotWheels2API.h"
#import "ImageBank.h"
#import "UserManager.h"

@interface collectionViewController () <UICarGridViewDelegate>
@property(nonatomic, strong) IBOutlet UIBarButtonItem *refreshButton;
@property(nonatomic, strong) IBOutlet UICarGridView   *carGridView;
@property(nonatomic, strong) IBOutlet UILabel         *emptyCollectionLabel;

@property(nonatomic, strong) UIBarButtonItem         *activityButton;
@property(nonatomic, strong) UIActivityIndicatorView *activityView;

@property(nonatomic, weak) CarManager *carManager;

@property bool collectionRequesting;

@property(nonatomic, weak) CarWrapper *selectedCarWrapper;
@end


@implementation collectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// get the car manager
	self.carManager = [CarManager getSingleton];
	
	// create the activity button for the navigation bar
	self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	[self.activityView startAnimating];
	
	self.activityButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityView];
	
	// setup car grid
	self.carGridView.carGridViewDelegate = self;
	
	// get the collection
	[self refreshCollection];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// refresh collection on view
//- (void)viewWillAppear:(BOOL)animated
// {
// [self refreshCollection];
// }




- (void)toggleRefreshActivity:(bool) show
{
	self.navigationItem.rightBarButtonItem = show ? self.activityButton : self.refreshButton;
}




- (IBAction)refreshButtonPressed:(id) sender
{
	[self refreshCollection];
}




- (void)refreshCollection
{
	// make sure we are not already refreshing
	if (self.collectionRequesting)
		return;
	
	// we are now requesting, disable the refresh button and show the activity indicator
	self.collectionRequesting = true;
	self.refreshButton.enabled = false;
	[self toggleRefreshActivity:true];
	
	// make the request
	[HotWheels2API getCollection:[UserManager getUserID] handler:^(NSError *error, NSMutableArray *cars)
	{
		self.collectionRequesting = false;
		
		// enable the refresh button and hide the activity indicator
		dispatch_async(dispatch_get_main_queue(), ^
		{
			self.refreshButton.enabled = true;
			[self toggleRefreshActivity:false];
			
			if (error || !cars)
				return;
		
			// update screen
			[self.carGridView setCars:cars];
			
			self.navigationItem.title = [NSString stringWithFormat:@"Collection (%i)", (int)cars.count];
			
			// show the "empty collection" label if did not get any results
			self.emptyCollectionLabel.hidden = cars.count > 0;
		});
	 }];
}





- (void)carWrapperSelected:(CarWrapper *)carWrapper
{
	self.selectedCarWrapper = carWrapper;
	[self performSegueWithIdentifier:@"collectionToDetails" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	// set the car the detail view should display
	detailsViewController *controller = (detailsViewController *)segue.destinationViewController;
	controller.carWrapper = self.selectedCarWrapper;
}
@end
