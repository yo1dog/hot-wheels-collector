//
//  hotwheels2FirstViewController.m
//  Hot Wheels 2.0
//
//  Created by Mike on 12/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "searchViewController.h"

#import "CarManager.h"
#import "CarCell.h"
#import "HotWheels2API.h"
#import "ImageBank.h"
#import "UserManager.h"

#import "detailsViewController.h"
#import "scannerViewController.h"

@interface searchViewController () <UISearchBarDelegate, UICollectionViewDataSource>
@property(nonatomic, weak) IBOutlet UISearchBar       *searchBar;
@property(nonatomic, weak) IBOutlet UICollectionView  *collectionView;
@property(nonatomic, weak) IBOutlet UIView            *activityView;
@property(nonatomic, weak) IBOutlet UILabel           *noSearchResultsLabel;
@property(nonatomic, weak) IBOutlet UIStoryboardSegue *detailsSegue;

@property(nonatomic, weak) CarManager *carManager;

@property int searchRequestNumber;
@property(nonatomic, strong) NSMutableArray  *searchResults;
@end




@implementation searchViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// get the car manager
	self.carManager = [CarManager getSingleton];
	
	// init some vars
	self.searchRequestNumber = 0;
	self.searchResults       = [NSMutableArray array];
	
	// hide the activity indicator
	[self toggleSearchBarActivity:false];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SearchHeaderView" forIndexPath:indexPath];
}




- (void)toggleSearchBarActivity:(bool) show
{
	self.activityView.hidden = !show;
	
	self.searchBar.frame = CGRectMake(
									  self.searchBar.frame.origin.x,
									  self.searchBar.frame.origin.y,
									  self.view.frame.size.width - (show ? 88 : 44),
									  self.searchBar.frame.size.height);
}




- (IBAction)badgeButtonPressed:(id) sender
{
	// if I refrence CarCellBadgeButton (sender) the reference gets overriden
	// get the car wrapper from the button
	CarWrapper *bbp_carWrapper = ((CarCellBadgeButton *)sender).carWrapper;
	
	// make request
	[bbp_carWrapper requestSetCarOwned:[UserManager getUserID] owned:!bbp_carWrapper.car.owned];
}





- (void)carUpdated:(CarWrapper *) carWrapper
{
	dispatch_async(dispatch_get_main_queue(), ^
	{
		if (carWrapper.searchIndexPath.row < [self.searchResults count])
			[self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:carWrapper.searchIndexPath]];
	});
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

- (void)finishSearch:(int)              searchRequestNumber
				cars:(NSMutableArray *) cars
			   error:(NSError *)        error
{
	// make sure the reponse is from the latest request
	if (searchRequestNumber != self.searchRequestNumber)
		return;
	
	// hide the activity indicator
	[self toggleSearchBarActivity:false];
	
	
	if (error || cars == NULL)
		return;
	
	
	// unregister previous seach results
	for (CarWrapper *carWrapper in self.searchResults)
	{
		[carWrapper unregisterSearchViewController];
		[self.carManager checkForRemoval:carWrapper];
	}
	
	// wipe the old search results
	[self.searchResults removeAllObjects];
	
	// add the new search results
	for (int i = 0; i < [cars count]; ++i)
	{
		// get/add the car from/to the car manager
		CarWrapper * carWrapper = [self.carManager getCarWrapper:cars[i]];
		
		// register self as the searchViewController
		[carWrapper registerSearchViewController:self indexPath:[NSIndexPath indexPathForRow:i inSection:0]];
		
		[self.searchResults addObject:carWrapper];
	}
	
	// update the screen
	[self.collectionView reloadData];
	
	if ([self.searchResults count] > 0)
	{
		// hide the "no reuslts" label
		self.noSearchResultsLabel.hidden = true;
		
		// scroll to the top
		[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:false];
	}
	
	// if we didn't get any results show the "no results" label
	else
		self.noSearchResultsLabel.hidden = false;
}





#pragma mark - UISearchBarDelegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	int searchRequestNumber = [self startSearch];
	
	// preform the search
	[HotWheels2API search:searchBar.text userID:[UserManager getUserID] completionHandler:^(NSError *sbsbc_error, NSMutableArray *sbsbc_cars)
	{
		dispatch_async(dispatch_get_main_queue(), ^
		{
			[self finishSearch:searchRequestNumber cars:sbsbc_cars error:sbsbc_error];
		});
	}];
	
	[searchBar resignFirstResponder];
}


#pragma mark - UICollectionView Datasource
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [self.searchResults count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	// get the cell at the index path
	CarCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"CarSearchResultCell_Search" forIndexPath:indexPath];
	
	// get the car wrapper from the search results
	CarWrapper *carWrapper = (CarWrapper *)self.searchResults[indexPath.row];
	
	// update the UI
	cell.label.text           = carWrapper.car.name;
	cell.imageView.image      = carWrapper.car.iconImage;
	cell.badgeImageView.image = carWrapper.car.owned ? [ImageBank getBadgeOwned] : [ImageBank getBadgeUnowned];
	cell.badgeImageView.alpha = carWrapper.carSetOwnedRequesting? 0.5f : 1.0f;
	
	// give the badge button the car wrapper so we know what to update when it is pressed
	cell.badgeButton.carWrapper = carWrapper;
	
	// if we don't have an image...
	if (carWrapper.car.iconImage == NULL)
	{
		// download the image
		[carWrapper downloadCarImage];
		
		// show the activity indicator
		if (![cell.activityView isAnimating])
			[cell.activityView startAnimating];
	}
	else
	{
		// hide the activity indicator
		if ([cell.activityView isAnimating])
			[cell.activityView stopAnimating];
	}
	
    return cell;
}



#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Deselect item
}




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	// set the car the detail view should display
	if ([segue.identifier isEqualToString:@"search_showDetails"])
	{
		detailsViewController *controller = (detailsViewController *)segue.destinationViewController;
		
		// get the car wrapper based on the selected cell
		NSArray *selectedIndexPaths = [self.collectionView indexPathsForSelectedItems];
		CarWrapper *carWrapper = self.searchResults[[selectedIndexPaths[0] row]];
		
		
		// set the new car wrapper and register
		controller.carWrapper     = carWrapper;
		controller.parentViewType = DVPV_SEARCH;
    }
}

@end
