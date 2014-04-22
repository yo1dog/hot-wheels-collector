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

@property int numRows;
@property int cellsWidth;
@property int cellsHeight;

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

int VIEW_PADDING = 500;

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
	
	[self createCarCells:cars];
	[self originizeCarCells];
	[self originizeMoreButton:showMoreButton];
	
	[self scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:false];
	[self viewCells];
}

- (void)addCars:(NSMutableArray *) cars
{
	[self addCars:cars showMoreButton:false];
}
- (void)addCars:(NSMutableArray *) cars showMoreButton:(bool) showMoreButton
{
	int newContentOffsetY = 0;
	
	if (self.carCells.count > 0)
	{
		int numRows = ((int)self.carCells.count / NUM_COLS) + (self.carCells.count % NUM_COLS > 0);
		newContentOffsetY = self.topPadding + PADDING_Y + (CELL_HEIGHT + CELL_PADDING_Y) * (numRows - 1) + CELL_HEIGHT * 0.5 - self.scrollIndicatorInsets.top;
	}
	
	int orginizeStartingFromCellIndex = (int)self.carCells.count;
	
	[self createCarCells:cars];
	[self originizeCarCells:orginizeStartingFromCellIndex];
	[self originizeMoreButton:showMoreButton];
	
	[self setContentOffset:CGPointMake(0, MAX(MIN(newContentOffsetY, self.contentSize.height - (self.bounds.size.height - self.scrollIndicatorInsets.bottom)), 0)) animated:true];
	[self viewCells];
}

- (void)sortCells:(NSComparisonResult (^)(CarCell* carCellA, CarCell*  carCellB)) comparator
{
	[self.carCells sortUsingComparator:comparator];
	[self originizeCarCells];
	
	[self scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:false];
	[self viewCells];
}



- (void)createCarCells:(NSMutableArray *) cars
{
	for (Car *car in cars)
	{
		CarCell *carCell = [[CarCell alloc] initWithCarWrapper:[CarManager getCarWrapper:car]];
		[carCell addTarget:self action:@selector(cellPressed:) forControlEvents:UIControlEventTouchUpInside];
		
		[self.carCells addObject:carCell];
	}
}

- (void)originizeCarCells
{
	[self originizeCarCells:0];
}
- (void)originizeCarCells:(int)startingFromCellIndex
{
	int col = startingFromCellIndex % NUM_COLS;
	int row = startingFromCellIndex / NUM_COLS;
	
	for (int i = startingFromCellIndex; i < self.carCells.count; ++i)
	{
		
		((CarCell *)self.carCells[i]).frame = CGRectMake(                  PADDING_X + (CELL_WIDTH  + CELL_PADDING_X) * col,
														 self.topPadding + PADDING_Y + (CELL_HEIGHT + CELL_PADDING_Y) * row,
														 CELL_WIDTH, CELL_HEIGHT);
		
		++col;
		if (col == NUM_COLS)
		{
			col = 0;
			++row;
		}
	}
	
	self.numRows = ((int)self.carCells.count / NUM_COLS) + (self.carCells.count % NUM_COLS > 0);
	self.cellsWidth  = CELL_WIDTH  * NUM_COLS      + CELL_PADDING_X * (NUM_COLS     - 1);
	self.cellsHeight = CELL_HEIGHT * self.numRows  + CELL_PADDING_Y * (self.numRows - 1);
	
	self.__contentSize = CGSizeMake(PADDING_X + self.cellsWidth, self.topPadding + PADDING_Y + self.cellsHeight + PADDING_Y);
	[self setContentSize:self.__contentSize];
}

- (void)originizeMoreButton:(bool)showMoreButton
{
	if (showMoreButton)
	{
		self.moreButton.frame = CGRectMake(PADDING_X + ((self.cellsWidth - (int)self.moreButton.frame.size.width) >> 1),
										   self.topPadding + PADDING_Y + self.cellsHeight + CELL_PADDING_Y,
										   self.moreButton.frame.size.width,
										   self.moreButton.frame.size.height);
		self.moreButton.enabled = true;
		[self.moreButton setTitle:@"Show More Results" forState:(UIControlStateNormal)];
		
		[self addSubview:self.moreButton];
		
		self.cellsHeight += CELL_PADDING_Y + self.moreButton.frame.size.height;
		
		self.__contentSize = CGSizeMake(PADDING_X + self.cellsWidth, self.topPadding + PADDING_Y + self.cellsHeight + PADDING_Y);
		[self setContentSize:self.__contentSize];
	}
	else
		[self.moreButton removeFromSuperview];
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
	int viewTop = (int)self.contentOffset.y - VIEW_PADDING;
	int viewHeight = VIEW_PADDING + (int)self.frame.size.height + VIEW_PADDING;
	
	// calucalte start and last index
	int i1 = ((viewTop - PADDING_Y - self.topPadding) / (CELL_HEIGHT + CELL_PADDING_Y)) * NUM_COLS;
	int i2 = i1 + (viewHeight / (CELL_HEIGHT + CELL_PADDING_Y) + 1) * NUM_COLS;
	
	// clamp these values. we have to clamp i1 AFTER we use it to calculate i2, otherwise the height would be offset if i1 < 0
	i1 = MAX(i1, 0);
	i2 = MIN(i2, (int)self.carCells.count);
	
	// show all visible cells
	for (int i = 0; i < self.carCells.count; ++i)
	{
		CarCell *carCell = self.carCells[i];
		
		if (i >= i1 && i < i2)
		{
			if (!carCell.superview)
				[self addSubview:carCell];
			
			[carCell viewed];
		}
		else
		{
			if (carCell.superview)
				[carCell removeFromSuperview];
		}
	}
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
