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

@property (nonatomic, strong) NSString *searchQuery;
@property int searchPage;
@property int searchNumberOfPages;

@property(nonatomic, weak) CarWrapper *selectedCarWrapper;
@end


@implementation searchViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// init some vars
	self.searchRequestNumber = 0;
	self.searchPage = 0;
	
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





- (void)search:(NSString *)query page:(int)page
{
	// TODO: cancel previous search
	
	// increment the search number and store it locally
	++self.searchRequestNumber;
	if (self.searchRequestNumber > 99)
		self.searchRequestNumber = 0;
	
	int searchRequestNumber = self.searchRequestNumber;
	
	
	// show the activity indicator
	[self toggleSearchBarActivity:true];
	
	[HotWheels2API search:query userID:[UserManager getLoggedInUserID] page:page completionHandler:^(HotWheels2APIError *error, NSMutableArray *cars, int numPages)
	{
		dispatch_async(dispatch_get_main_queue(), ^
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
			
			// set search vars
			self.searchPage          = page;
			self.searchNumberOfPages = numPages;
			self.searchQuery         = query;
			
			// show the cars
			if (page > 0)
				[self.carGridView addCars:cars showMoreButton:page < numPages - 1];
			else
			{
				[self.carGridView setCars:cars showMoreButton:page < numPages - 1];
				
				// if we didn't get any results show the "no results" label
				self.noSearchResultsLabel.hidden = [cars count] > 0;
			}
		});
	}];
}





- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[self search:searchBar.text page:0];
	[searchBar resignFirstResponder];
}
- (void)moreButtonPressed:(UIButton *)moreButton
{
	[moreButton setTitle:@"Loading..." forState:UIControlStateNormal];
	moreButton.enabled = false;
	
	[self search:self.searchQuery page:self.searchPage + 1];
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
