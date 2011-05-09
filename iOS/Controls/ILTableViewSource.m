//
//  ILTableViewSource.m
//  Controls
//
//  Created by ∞ on 09/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ILTableViewSource.h"

#import "objc/runtime.h"

static char ILTableViewCellDidSelectKey = 0;

@implementation UITableViewCell (ILTableViewAdditions)

- (void(^)()) didSelect;
{
	return objc_getAssociatedObject(self, &ILTableViewCellDidSelectKey);
}

- (void) setDidSelect:(void(^)()) s;
{
	objc_setAssociatedObject(self, &ILTableViewCellDidSelectKey, s, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end


@interface ILTableViewSource () <ILTableViewSectionMutationDelegate>
@end


@implementation ILTableViewSource

@synthesize tableView;

- (void) dealloc
{
	self.tableView = nil;
	[_sectionsArray release];
	
	[self removeObserver:self forKeyPath:@"sections"];
	[super dealloc];
}

// -----------------------------

static const char ILTableViewObservingContext = 0;

+ (id) tableViewSource;
{
	return [[self new] autorelease];
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		_sectionsArray = [NSMutableArray new];
		[self addObserver:self forKeyPath:@"sections" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:(void*) &ILTableViewObservingContext];
	}
	return self;
}

- (void) setAsDelegateAndDataSourceForTableView;
{
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
}

- (void) setTableView:(UITableView *) tv;
{
	if (tableView != tv) {
		if (tableView && tableView.delegate == self)
			tableView.delegate = nil;
		
		if (tableView && tableView.dataSource == self)
			tableView.dataSource = nil;
		
		[tableView release];
		tableView = [tv retain];
		
		if (tv && !tv.delegate)
			tv.delegate = self;
		
		if (tv && !tv.dataSource)
			tv.dataSource = self;
	}
}

- (NSArray*) sections;
{
	return _sectionsArray;
}

- (void) setSections:(NSArray*) a;
{
	[_sectionsArray setArray:a];
}

- (NSMutableArray*) mutableSections;
{
	return [self mutableArrayValueForKey:@"sections"];
}

// -----------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView;
{
	return [_sectionsArray count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	return [[_sectionsArray objectAtIndex:section] countOfRows];
}

- (UITableViewCell *) tableView:(UITableView *) tv cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	return [[_sectionsArray objectAtIndex:[indexPath section]] cellForRowAtIndex:[indexPath row] inTableView:tv];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
	return [[_sectionsArray objectAtIndex:section] title];
}

- (void) tableView:(UITableView *) tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
	UITableViewCell* cell = [tv cellForRowAtIndexPath:indexPath];
	if (cell.didSelect)
		(cell.didSelect)();
}

// -----------------------------

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
	if (context != &ILTableViewObservingContext)
		return;
	
	NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
	switch (changeKind) {
		case NSKeyValueChangeInsertion:
			for (id <ILTableViewSection> s in [change objectForKey:NSKeyValueChangeNewKey])
				[s setMutationDelegate:self];
			
			[self.tableView insertSections:[change objectForKey:NSKeyValueChangeIndexesKey] withRowAnimation:UITableViewRowAnimationFade];
			
			
			break;
			
		case NSKeyValueChangeRemoval:
			for (id <ILTableViewSection> s in [change objectForKey:NSKeyValueChangeOldKey])
				[s setMutationDelegate:nil];
			
			[self.tableView deleteSections:[change objectForKey:NSKeyValueChangeIndexesKey] withRowAnimation:UITableViewRowAnimationFade];
			break;

		case NSKeyValueChangeReplacement:
			for (id <ILTableViewSection> s in [change objectForKey:NSKeyValueChangeOldKey])
				[s setMutationDelegate:nil];
			for (id <ILTableViewSection> s in [change objectForKey:NSKeyValueChangeNewKey])
				[s setMutationDelegate:self];
			
			[self.tableView reloadSections:[change objectForKey:NSKeyValueChangeIndexesKey] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		default:
		case NSKeyValueChangeSetting:
			for (id <ILTableViewSection> s in [change objectForKey:NSKeyValueChangeOldKey])
				[s setMutationDelegate:nil];
			for (id <ILTableViewSection> s in [change objectForKey:NSKeyValueChangeNewKey])
				[s setMutationDelegate:self];
			
			[self.tableView reloadData];
			break;
	}
}

// -----------------------------

- (NSArray*) indexPathsForIndexes:(NSIndexSet*) ixs inSection:(NSInteger) section;
{
	NSMutableArray* arr = [NSMutableArray arrayWithCapacity:[ixs count]];
	
	NSInteger i = [ixs firstIndex];
	while (i != NSNotFound) {
		[arr addObject:[NSIndexPath indexPathForRow:i inSection:section]];
		i = [ixs indexGreaterThanIndex:i];
	}
	
	return arr;
}

- (void) sectionDidChange:(id <ILTableViewSection>)section;
{
	NSInteger sectionIndex = [_sectionsArray indexOfObject:section];
	NSAssert(sectionIndex != NSNotFound, @"Unknown section called a mutation method");
	
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
}

- (void) section:(id <ILTableViewSection>)section didInsertRowsAtIndexes:(NSIndexSet *)indexes;
{
	NSInteger sectionIndex = [_sectionsArray indexOfObject:section];
	NSAssert(sectionIndex != NSNotFound, @"Unknown section called a mutation method");
	
	[self.tableView insertRowsAtIndexPaths:[self indexPathsForIndexes:indexes inSection:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
}

- (void) section:(id <ILTableViewSection>)section didDeleteRowsAtIndexes:(NSIndexSet *)indexes;
{
	NSInteger sectionIndex = [_sectionsArray indexOfObject:section];
	NSAssert(sectionIndex != NSNotFound, @"Unknown section called a mutation method");
	
	[self.tableView deleteRowsAtIndexPaths:[self indexPathsForIndexes:indexes inSection:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];	
}

- (void) section:(id <ILTableViewSection>)section didReplaceRowsAtIndexes:(NSIndexSet *)indexes;
{
	NSInteger sectionIndex = [_sectionsArray indexOfObject:section];
	NSAssert(sectionIndex != NSNotFound, @"Unknown section called a mutation method");
	
	[self.tableView reloadRowsAtIndexPaths:[self indexPathsForIndexes:indexes inSection:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];	
}

@end

@implementation ILTableViewSection

@synthesize mutationDelegate, title, cellForRowObject;

- (void) dealloc
{
	[self removeObserver:self forKeyPath:@"rows"];
	
	self.title = nil;
	self.cellForRowObject = nil;
	[_rowsArray release];
	[super dealloc];
}

// -----------------------------

+ (id) tableViewSection;
{
	return [[self new] autorelease];
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		_rowsArray = [NSMutableArray new];
		[self addObserver:self forKeyPath:@"rows" options:0 context:(void*) &ILTableViewObservingContext];
	}
	return self;
}

- (NSArray *) rows;
{
	return _rowsArray;
}

- (void) setRows:(NSArray *) a;
{
	[_rowsArray setArray:a];
}

- (NSMutableArray *) mutableRows;
{
	return [self mutableArrayValueForKey:@"rows"];
}

// -----------------------------

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
	if (context != &ILTableViewObservingContext)
		return;
	
	NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
	switch (changeKind) {
		case NSKeyValueChangeInsertion:
			[self.mutationDelegate section:self didInsertRowsAtIndexes:[change objectForKey:NSKeyValueChangeIndexesKey]];
			break;
			
		case NSKeyValueChangeRemoval:
			[self.mutationDelegate section:self didDeleteRowsAtIndexes:[change objectForKey:NSKeyValueChangeIndexesKey]];
			break;
			
		case NSKeyValueChangeReplacement:
			[self.mutationDelegate section:self didReplaceRowsAtIndexes:[change objectForKey:NSKeyValueChangeIndexesKey]];
			break;
			
		default:
		case NSKeyValueChangeSetting:
			[self.mutationDelegate sectionDidChange:self];
			break;
	}	
}

// -----------------------------

- (NSUInteger) countOfRows;
{
	return [_rowsArray count];
}

- (UITableViewCell*) cellForRowAtIndex:(NSUInteger) index inTableView:(UITableView*) tv;
{
	id x = [_rowsArray objectAtIndex:index];
	
	if (![x isKindOfClass:[UITableViewCell class]]) {
		NSAssert(self.cellForRowObject != nil, @"You must set .cellForRowObject if you use objects in the .rows array other than UITableViewCells.");
		x = (self.cellForRowObject)(x, index, tv);
	}
	
	return x;
}

@end
