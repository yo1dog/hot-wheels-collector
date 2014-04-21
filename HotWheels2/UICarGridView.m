//
//  UICarGridView.m
//  HotWheels 2.0
//
//  Created by Mike on 4/6/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "UICarGridView.h"
#import "CarCell.h"
#import "CarManager.h"
#import "CarWrapper.h"

@interface UICarGridView () <UIScrollViewDelegate>
@property(nonatomic, strong) NSMutableArray *carCells;
@property(nonatomic, strong) UIButton *moreButton;

@property bool shownAllCellsForFirstTime;
@property int maxShownForFirstTimeViewTop;
@property int maxShownForFirstTimeStartCellIndex;
@property int maxShownForFirstTimeLastCellIndex;

@property CGSize __contentSize;
@end

@implementation UICarGridView

int NUM_COLS = 2;
int PADDING_X = 7;
int PADDING_Y = 7;

int CELL_WIDTH  = 150;
int CELL_HEIGHT = 130;
int CELL_PADDING_X = 6;
int CELL_PADDING_Y = 25;

int VIEW_BOTTOM_PADDING = 200;

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
	
	self.delegate = self;
	self.canCancelContentTouches = true;
	
	self.carCells = [[NSMutableArray array] init];
	self.topPadding = 0;
	
	self.moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[self.moreButton addTarget:self action:@selector(moreButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	
	self.moreButton.frame = CGRectMake(0, 0, 160, 30);
	self.moreButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
	return true;
}



- (void)setCars:(NSMutableArray *) cars
{
	[self setCars:cars showMoreButton:false];
}
- (void)setCars:(NSMutableArray *)cars showMoreButton:(bool)showMoreButton
{
	// remove all car cell subviews
	for (CarCell *carCell in self.carCells)
		[carCell removeFromSuperview];
	
	// reset
	[self.carCells removeAllObjects];
	self.shownAllCellsForFirstTime = false;
	self.maxShownForFirstTimeViewTop = -1;
	self.maxShownForFirstTimeStartCellIndex = -1;
	self.maxShownForFirstTimeLastCellIndex = 0;
	
	[self addCarCells:cars showMoreButton:showMoreButton];
	[self scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:true];
}

- (void)addCars:(NSMutableArray *) cars
{
	[self addCars:cars showMoreButton:false];
}
- (void)addCars:(NSMutableArray *) cars showMoreButton:(bool) showMoreButton
{
	// reset
	self.shownAllCellsForFirstTime = false;
	self.maxShownForFirstTimeViewTop = -1;
	self.maxShownForFirstTimeStartCellIndex = -1;
	
	int newContentOffsetY = 0;
	
	if (self.carCells.count > 0)
	{
		int numRows = ((int)self.carCells.count / NUM_COLS) + (self.carCells.count % NUM_COLS > 0);
		newContentOffsetY = self.topPadding + PADDING_Y + (CELL_HEIGHT + CELL_PADDING_Y) * (numRows - 1) + CELL_HEIGHT * 0.5 - self.scrollIndicatorInsets.top;
	}
	
	[self addCarCells:cars showMoreButton:showMoreButton];
	[self setContentOffset:CGPointMake(0, MAX(MIN(newContentOffsetY, self.contentSize.height - (self.bounds.size.height - self.scrollIndicatorInsets.bottom)), 0)) animated:true];
}

- (void)addCarCells:(NSMutableArray *) cars showMoreButton:(bool) showMoreButton
{
	// add the new search results
	int col = (int)self.carCells.count % NUM_COLS;
	int row = (int)self.carCells.count / NUM_COLS;
	for (Car *car in cars)
	{
		// get/add the car from/to the car manager
		CarWrapper * carWrapper = [CarManager getCarWrapper:car];
		
		int x =                   PADDING_X + (CELL_WIDTH  + CELL_PADDING_X) * col;
		int y = self.topPadding + PADDING_Y + (CELL_HEIGHT + CELL_PADDING_Y) * row;
		
		CarCell *carCell = [[CarCell alloc] initWithFrame:CGRectMake(x, y, CELL_WIDTH, CELL_HEIGHT) andCarWrapper:carWrapper];
		[carCell addTarget:self action:@selector(cellPressed:) forControlEvents:UIControlEventTouchUpInside];
		
		[self.carCells addObject:carCell];
		//[self addSubview:carCell];
		
		++col;
		if (col == NUM_COLS)
		{
			col = 0;
			++row;
		}
	}
	
	int numRows = ((int)self.carCells.count / NUM_COLS) + (self.carCells.count % NUM_COLS > 0);
	int cellsWidth  = CELL_WIDTH  * NUM_COLS + CELL_PADDING_X * (NUM_COLS - 1);
	int cellsHeight = CELL_HEIGHT * numRows  + CELL_PADDING_Y * (numRows - 1);
	
	if (showMoreButton)
	{
		self.moreButton.frame = CGRectMake(PADDING_X + ((cellsWidth - (int)self.moreButton.frame.size.width) >> 1),
										   self.topPadding + PADDING_Y + cellsHeight + CELL_PADDING_Y,
										   self.moreButton.frame.size.width,
										   self.moreButton.frame.size.height);
		self.moreButton.enabled = true;
		[self.moreButton setTitle:@"Show More Results" forState:(UIControlStateNormal)];
		
		[self addSubview:self.moreButton];
		
		cellsHeight += CELL_PADDING_Y + self.moreButton.frame.size.height;
	}
	else
		[self.moreButton removeFromSuperview];
	
	self.__contentSize = CGSizeMake(PADDING_X + cellsWidth, self.topPadding + PADDING_Y + cellsHeight + PADDING_Y);
	[self setContentSize:self.__contentSize];
	[self viewCells];
}

- (void)setContentSize:(CGSize)contentSize
{
	// TODO: keep internals from reseting content size to 0 when the view controller disppears.... very icky
	[super setContentSize:self.__contentSize];
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self viewCells];
}

- (void)viewCells
{
	//if (self.shownAllCellsForFirstTime)
	//	return;
	
	// get view top
	int viewTop = MAX((int)self.contentOffset.y, 0);
	
	// if we have already viewed lower than this, no point in continuing
	//if (viewTop <= self.maxShownForFirstTimeViewTop)
	//	return;
	
	//self.maxShownForFirstTimeViewTop = viewTop;
	
	
	// calucalte start index
	int i1 = ((viewTop - PADDING_Y - self.topPadding) / (CELL_HEIGHT + CELL_PADDING_Y)) * NUM_COLS;
	
	// if we have already shown past the first cell, no point in continuing
	//if (i1 <= self.maxShownForFirstTimeStartCellIndex)
	//	return;
	
	//self.maxShownForFirstTimeStartCellIndex = i1;
	
	
	// calculate the last index
	int viewHeight = (int)self.frame.size.height + VIEW_BOTTOM_PADDING;
	int i2 = i1 + (viewHeight / (CELL_HEIGHT + CELL_PADDING_Y) + 1) * NUM_COLS;
	
	if (i2 >= self.carCells.count)
	{
		i2 = (int)self.carCells.count;
		//self.shownAllCellsForFirstTime = true;
	}
	
	// if we have already shown past the last cell, no point in continuing
	//if (i2 <= self.maxShownForFirstTimeLastCellIndex)
	//	return;
	
	
	//NSLog(@"%i\t%i - %i/%i", viewTop, self.maxShownForFirstTimeLastCellIndex + 1, i2, (int)self.carCells.count);
	
	// show all cells from the last cell we have shown (exclusive) to the last visibile cell (inclusive)
	for (int i = 0; i < self.carCells.count; ++i)
	{
		CarCell *carCell = self.carCells[i];
		
		if (i >= i1 && i < i2)
		{
			if (!carCell.superview)
				[self addSubview:carCell];
		}
		else
		{
			if (carCell.superview)
				[carCell removeFromSuperview];
		}
	}
	
	
	for (int i = self.maxShownForFirstTimeLastCellIndex; i < i2; ++i)
		[self.carCells[i] showForFirstTime];
	
	self.maxShownForFirstTimeLastCellIndex = i2;
}


- (void)cellPressed:(CarCell *)carCell
{
	if (self.carGridViewDelegate)
		[self.carGridViewDelegate carWrapperSelected:[carCell getCarWrapper]];
}
- (void)moreButtonPressed
{
	if (self.carGridViewDelegate)
		[self.carGridViewDelegate moreButtonPressed:self.moreButton];
}
@end
