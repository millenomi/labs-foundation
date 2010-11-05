//
//  ILNIBTableViewCell.m
//  NIBTableViewCells
//
//  Created by ∞ on 05/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILNIBTableViewCell.h"


@implementation ILNIBTableViewCell

- (id) initWithNibName:(NSString*) name bundle:(NSBundle*) bundle reuseIdentifier:(NSString*) reuseIdent;
{
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdent])) {
		
		if (!bundle)
			bundle = [NSBundle bundleForClass:[self class]];
		
		[bundle loadNibNamed:name owner:self options:nil];
		
		NSAssert(cellContentView, @"Connect the cellContentView outlet in the NIB for this class!");
		
		cellContentView.frame = self.contentView.bounds;
		[self.contentView addSubview:cellContentView];
		
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
	[cellContentView release];
	[super dealloc];
}


+ reuseIdentifier;
{
	return NSStringFromClass(self);
}

@end
