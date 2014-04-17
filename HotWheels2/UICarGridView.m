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
@property(nonatomic, strong) NSMutableArray  *carCells;
@property int viewCellsLength;

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
int CELL_PADDING_Y = 20;

int VIEW_BOTTOM_PADDING = 200;

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
	
    if (self)
	{
		self.delegate = self;
		self.canCancelContentTouches = true;
		
		self.carCells = [[NSMutableArray array] init];
		self.topPadding = 0;
    }
	
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
	return YES;
}

- (void)setCars:(NSMutableArray *) cars;
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
	
	// add the new search results
	int col = 0;
	int row = 0;
	int width = 0;
	int height = 0;
	for (Car *car in cars)
	{
		// get/add the car from/to the car manager
		CarWrapper * carWrapper = [CarManager getCarWrapper:car];
		
		int x = PADDING_X + col * (CELL_WIDTH  + CELL_PADDING_X);
		int y = PADDING_Y + row * (CELL_HEIGHT + CELL_PADDING_Y) + self.topPadding;
		
		CarCell *carCell = [[CarCell alloc] initWithFrame:CGRectMake(x, y, CELL_WIDTH, CELL_HEIGHT) andCarWrapper:carWrapper];
		[carCell addTarget:self action:@selector(cellPressed:) forControlEvents:UIControlEventTouchUpInside];
		
		[self.carCells addObject:carCell];
		[self addSubview:carCell];
		
		width  = MAX(x + CELL_WIDTH , width );
		height = MAX(y + CELL_HEIGHT, height);
		
		++col;
		if (col == NUM_COLS)
		{
			col = 0;
			++row;
		}
	}
	
	self.__contentSize = CGSizeMake(width + PADDING_X, height + PADDING_Y);
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
	if (self.shownAllCellsForFirstTime)
		return;
	
	// get view top
	int viewTop = MAX((int)self.contentOffset.y, 0);
	
	// if we have already viewed lower than this, no point in continuing
	if (viewTop <= self.maxShownForFirstTimeViewTop)
		return;
	
	self.maxShownForFirstTimeViewTop = viewTop;
	
	
	// calucalte start index
	int i1 = ((viewTop - PADDING_Y - self.topPadding) / (CELL_HEIGHT + CELL_PADDING_Y)) * NUM_COLS;
	
	// if we have already shown past the first cell, no point in continuing
	if (i1 <= self.maxShownForFirstTimeStartCellIndex)
		return;
	
	self.maxShownForFirstTimeStartCellIndex = i1;
	
	
	// calculate the last index
	int viewHeight = (int)self.frame.size.height + VIEW_BOTTOM_PADDING;
	int i2 = i1 + (viewHeight / (CELL_HEIGHT + CELL_PADDING_Y) + 1) * NUM_COLS;
	
	if (i2 >= self.carCells.count)
	{
		i2 = (int)self.carCells.count;
		self.shownAllCellsForFirstTime = true;
	}
	
	// if we have already shown past the last cell, no point in continuing
	if (i2 <= self.maxShownForFirstTimeLastCellIndex)
		return;
	
	
	//NSLog(@"%i\t%i - %i/%i", viewTop, self.maxShownForFirstTimeLastCellIndex + 1, i2, (int)self.carCells.count);
	
	// show all cells from the last cell we have shown (exclusive) to the last visibile cell (inclusive)
	for (int i = self.maxShownForFirstTimeLastCellIndex; i < i2; ++i)
		[self.carCells[i] showForFirstTime];
	
	self.maxShownForFirstTimeLastCellIndex = i2;
}


- (void)cellPressed:(CarCell *)carCell
{
	if (self.carGridViewDelegate)
		[self.carGridViewDelegate carWrapperSelected:[carCell getCarWrapper]];
}
@end
