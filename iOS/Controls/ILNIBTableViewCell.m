//
//  ILNIBTableViewCell.m
//  NIBTableViewCells
//
//  Created by ∞ on 05/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILNIBTableViewCell.h"


@implementation ILNIBTableViewCell

static NSMutableDictionary* ILNIBTableViewCellCache = nil;

+ (UINib*) cachedNibWithName:(NSString*) name bundle:(NSBundle*) bundle;
{
	static Class UINibClass = Nil;
	static BOOL checked = NO;
	if (!checked) {
		UINibClass = NSClassFromString(@"UINib");
		
		if (UINibClass)
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];

		checked = YES;
	}
	
	if (!UINibClass)
		return nil;

	
	if (!bundle)
		bundle = [NSBundle mainBundle];
	
	if (!ILNIBTableViewCellCache)
		ILNIBTableViewCellCache = [NSMutableDictionary new];
	
	NSMutableDictionary* nibsByName = [ILNIBTableViewCellCache objectForKey:[bundle bundleIdentifier]];
	if (!nibsByName) {
		nibsByName = [NSMutableDictionary dictionary];
		[ILNIBTableViewCellCache setObject:nibsByName forKey:[bundle bundleIdentifier]];
	}
	
	UINib* result = [nibsByName objectForKey:name];
	if (!result) {
		result = [UINib nibWithNibName:name bundle:bundle];
		[nibsByName setObject:result forKey:name];
	}
	
	return result;
}

+ (void) didReceiveMemoryWarning:(NSNotification*) n;
{
	[ILNIBTableViewCellCache release];
	ILNIBTableViewCellCache = nil;
}

- (id) initWithNibName:(NSString*) name bundle:(NSBundle*) bundle reuseIdentifier:(NSString*) reuseIdent;
{
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdent])) {
		
		if (!bundle)
			bundle = [NSBundle bundleForClass:[self class]];
		
		UINib* n = [[self class] cachedNibWithName:name bundle:bundle];
		if (n)
			[n instantiateWithOwner:self options:nil];
		else
			[bundle loadNibNamed:name owner:self options:nil];
		
		NSAssert(self.cellContentView, @"Connect the cellContentView outlet in the NIB for this class!");
		
		self.cellContentView.frame = self.contentView.bounds;
		self.cellContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		[self.contentView addSubview:self.cellContentView];
		
	}
	
	return self;
}

- (id) initReusable:(BOOL) allowReuse;
{
	return [self initWithNibName:NSStringFromClass(self->isa) bundle:[NSBundle bundleForClass:self->isa] reuseIdentifier:(allowReuse? [self->isa reuseIdentifier] : nil)];
}

- (id) init;
{
	return [self initReusable:YES];
}

- (void) dealloc
{
	self.cellContentView = nil;
	[super dealloc];
}


+ reuseIdentifier;
{
	return NSStringFromClass(self);
}

@synthesize cellContentView;

@end
