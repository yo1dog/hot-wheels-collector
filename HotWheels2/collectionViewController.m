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
@property(nonatomic, strong) IBOutlet UIButton        *sortOrderButton;

@property(nonatomic, strong) UIBarButtonItem         *activityButton;
@property(nonatomic, strong) UIActivityIndicatorView *activityView;

@property(nonatomic, strong) NSArray *cars;
@property bool collectionRequesting;
@property int  sortBy;
@property int  sortOrder;
@property(nonatomic, strong) NSString *filterString;

@property(nonatomic, weak) CarWrapper *selectedCarWrapper;
@end


@implementation collectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// create the activity button for the navigation bar
	self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	[self.activityView startAnimating];
	
	self.activityButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityView];
	
	// setup car grid
	self.carGridView.topPadding = 112;
	self.carGridView.carGridViewDelegate = self;
	
	self.sortBy    = 0;
	self.sortOrder = 1;
	
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
	[HotWheels2API getCollection:[UserManager getLoggedInUserID] completionHandler:^(HotWheels2APIError *error, NSMutableArray *cars)
	{
		self.collectionRequesting = false;
		
		// enable the refresh button and hide the activity indicator
		self.refreshButton.enabled = true;
		[self toggleRefreshActivity:false];
		
		if (error)
		{
			[[error createAlert:@"Unable to get Collection"] show];
			return;
		}
	
		// update screen
		self.cars = cars;
		[self sortAndFilter];
		
		self.navigationItem.title = [NSString stringWithFormat:@"Collection (%i)", (int)cars.count];
		
		// show the "empty collection" label if did not get any results
		self.emptyCollectionLabel.hidden = cars.count > 0;
	 }];
}



- (IBAction)sortBySegmentedControlValueChanged:(UISegmentedControl *) sortBySegmentedControl
{
	self.sortBy = sortBySegmentedControl.selectedSegmentIndex;
	self.sortOrder *= -1; // date should default to desc (newest) while name should default to asc (A-Z)
	
	[self setSortOrderButtonText];
	[self sortAndFilter];
}
- (IBAction)sortOrderButtonPressed:(UIButton *) sortOrderButton;
{
	self.sortOrder *= -1;
	
	[self setSortOrderButtonText];
	[self sortAndFilter];
}
- (IBAction)filterTextFieldChanged:(UITextField *) filterTextField
{
	self.filterString = filterTextField.text;
	
	[self sortAndFilter];
}

- (void)setSortOrderButtonText
{
	[self.sortOrderButton setTitle:(self.sortBy == 0?
									self.sortOrder == 1? @"A - Z"  : @"Z - A" :
									self.sortOrder == 1? @"Oldest" : @"Newest")
						  forState:UIControlStateNormal];
}

- (void)sortAndFilter
{
	// filter
	NSMutableArray *filteredCars;
	
	if (self.filterString && self.filterString.length > 0)
	{
		filteredCars = [[NSMutableArray alloc] init];
		for (Car *car in self.cars)
		{
			if ([car.name rangeOfString:self.filterString options:NSCaseInsensitiveSearch].location != NSNotFound)
				[filteredCars addObject:car];
		}
	}
	else
		filteredCars = [[NSMutableArray alloc] initWithArray:self.cars copyItems:false];
	
	// set cars
	[self.carGridView setCars:filteredCars];
	
	// sort
	[self.carGridView sortCells:^NSComparisonResult(CarCell *carCellA, CarCell *carCellB)
	{
		Car *carA = [carCellA getCarWrapper].car;
		Car *carB = [carCellB getCarWrapper].car;
		
		if (self.sortBy == 0)
			return [carA.sortName caseInsensitiveCompare:carB.sortName] * self.sortOrder;
		else
		{
			if (carA.ownedTimestamp < carB.ownedTimestamp)
				return -1 * self.sortOrder;
			else if (carA.ownedTimestamp > carB.ownedTimestamp)
				return self.sortOrder;
			else
				return 0;
		}
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

-(void)moreButtonPressed:(UIButton *)moreButton {}
@end
