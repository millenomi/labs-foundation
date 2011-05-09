//
//  RootViewController.m
//  TableViewSourceSample
//
//  Created by ∞ on 09/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

#import "ILTableViewSource.h"

@interface RootViewController ()

@property(retain, nonatomic) ILTableViewSource* source;

@property(copy, nonatomic) ILTableViewSectionCellForRowObject stringsToCells;

@end


@implementation RootViewController

@synthesize source, stringsToCells;

- (void) dealloc
{
	self.source = nil;
	self.stringsToCells = nil;
	[super dealloc];
}


- (void) viewDidLoad;
{
	[super viewDidLoad];
	
	self.stringsToCells = ^ UITableViewCell* (id x, NSInteger i, UITableView* tv) {
		
		UITableViewCell* cell = [tv dequeueReusableCellWithIdentifier:@"CountCell"];
		
		if (!cell)
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CountCell"] autorelease];
		
		cell.textLabel.text = x;
		return cell;
	};
	
	self.source = [ILTableViewSource tableViewSource];
	self.source.tableView = self.tableView;
	[self.source setAsDelegateAndDataSourceForTableView];
	
	ILTableViewSection* one = [ILTableViewSection tableViewSection];
	one.title = @"One";
	
	one.rows = [NSArray arrayWithObjects:
				 @"1", @"2", @"3", @"4", @"5", nil];
	
	one.cellForRowObject = self.stringsToCells;
	
	self.source.sections = [NSArray arrayWithObjects:one, nil];
	
	[self performSelector:@selector(more) withObject:nil afterDelay:2.0];
}

- (void) more;
{
	ILTableViewSection* two = [ILTableViewSection tableViewSection];
	two.title = @"One";
	
	two.rows = [NSArray arrayWithObjects:
				@"6", @"7", @"8", @"9", @"0", @"1", @"2", @"3", @"4", @"5", nil];
	
	two.cellForRowObject = self.stringsToCells;
		

	ILTableViewSection* evenMore = [ILTableViewSection tableViewSection];
	
	UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.text = @"Even more";
	
	evenMore.rows = [NSArray arrayWithObjects:
					 cell, nil];
	
	[self.source.mutableSections addObjectsFromArray:
	 [NSArray arrayWithObjects:
	  two, evenMore, nil]];
	
	[self performSelector:@selector(removeSome) withObject:nil afterDelay:2.0];
		
}

- (void) removeSome;
{
	ILTableViewSection* section = [self.source.sections objectAtIndex:1];
	[section.mutableRows removeObjectsInRange:NSMakeRange(2, 7)];
}

@end

