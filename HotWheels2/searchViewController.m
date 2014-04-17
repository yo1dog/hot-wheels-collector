//
//  hotwheels2FirstViewController.m
//  Hot Wheels 2.0
//
//  Created by Mike on 12/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "searchViewController.h"
#import "detailsViewController.h"
#import "CarManager.h"
#import "UICarGridView.h"
#import "HotWheels2API.h"
#import "ImageBank.h"
#import "UserManager.h"

@interface searchViewController () <UISearchBarDelegate, UICarGridViewDelegate>
@property(nonatomic, strong) IBOutlet UISearchBar   *searchBar;
@property(nonatomic, strong) IBOutlet UICarGridView *carGridView;
@property(nonatomic, strong) IBOutlet UIView        *activityView;
@property(nonatomic, strong) IBOutlet UILabel       *noSearchResultsLabel;
@property(nonatomic, strong) IBOutlet UIImageView   *qrCodeImageView;

@property int searchRequestNumber;
@property(nonatomic, weak) CarWrapper *selectedCarWrapper;
@end


@implementation searchViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// init some vars
	self.searchRequestNumber = 0;
	
	// hide the activity indicator
	[self toggleSearchBarActivity:false];
	
	// setup the car grid
	self.carGridView.topPadding = self.searchBar.frame.size.height;
	self.carGridView.carGridViewDelegate = self;
	
	//[self.qrCodeImageView setImage:[self.qrCodeImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
	self.qrCodeImageView.layer.cornerRadius = 3;
	self.qrCodeImageView.layer.masksToBounds = true;
}


- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}




- (void)toggleSearchBarActivity:(bool) show
{
	self.activityView.hidden = !show;
	
	self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x,
									  self.searchBar.frame.origin.y,
									  self.view.frame.size.width - (show ? 88 : 44),
									  self.searchBar.frame.size.height);
}





- (int)startSearch
{
	// TODO: cancel previous search
	
	// increment the search number and store it locally
	++self.searchRequestNumber;
	if (self.searchRequestNumber > 100)
		self.searchRequestNumber = 0;
	
	// show the activity indicator
	[self toggleSearchBarActivity:true];
	
	return self.searchRequestNumber;
}

- (void)finishSearch:(int)                  searchRequestNumber
			   error:(HotWheels2APIError *) error
				cars:(NSMutableArray *)     cars
{
	// make sure the reponse is from the latest request
	if (searchRequestNumber != self.searchRequestNumber)
		return;
	
	// hide the activity indicator
	[self toggleSearchBarActivity:false];
	
	if (error)
	{
		[[error createAlert:@"Search Failed"] show];
		return;
	}
	
	[self.carGridView setCars:cars];
	
	if ([cars count] > 0)
	{
		// hide the "no reuslts" label
		self.noSearchResultsLabel.hidden = true;
		
		// scroll to the top
		[self.carGridView setContentOffset:CGPointZero animated:false];
	}
	
	// if we didn't get any results show the "no results" label
	else
		self.noSearchResultsLabel.hidden = false;
}





- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	int searchRequestNumber = [self startSearch];
	
	// preform the search
	[HotWheels2API search:searchBar.text userID:[UserManager getLoggedInUserID] completionHandler:^(HotWheels2APIError *error, NSMutableArray *cars)
	{
		dispatch_async(dispatch_get_main_queue(), ^
		{
			[self finishSearch:searchRequestNumber error:error cars:cars];
		});
	}];
	
	[searchBar resignFirstResponder];
}



- (void)carWrapperSelected:(CarWrapper *)carWrapper
{
	self.selectedCarWrapper = carWrapper;
	[self performSegueWithIdentifier:@"searchToDetails" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	// set the car the detail view should display
	if ([segue.identifier isEqualToString:@"searchToDetails"])
	{
		detailsViewController *controller = (detailsViewController *)segue.destinationViewController;
		controller.carWrapper = self.selectedCarWrapper;
    }
}

@end
