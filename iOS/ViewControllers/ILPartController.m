//
//  ILPartController.m
//  ILViewController
//
//  Created by ∞ on 20/04/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILPartController.h"


@implementation ILPartController

+ (NSBundle*) nibBundle;
{
	return [NSBundle bundleForClass:self];
}

- (id) initWithNibName:(NSString*) name bundle:(NSBundle*) b;
{
	if (self = [super init]) {
		nibName = [name copy];
		nibBundle = b? [b retain] : [[self class] nibBundle];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
	
	return self;
}

- (id) init;
{
	return [self initWithNibName:NSStringFromClass(self->isa) bundle:nil];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	
	self.view = nil;
	[self clearOutlets];
	[managedOutlets release];
	
	[nibName release];
	[nibBundle release];
	
	[super dealloc];
}


@synthesize view;
- (UIView*) view;
{
	if (!view)
		[self loadView];
	
	return view;
}

- (BOOL) isViewLoaded;
{
	return view != nil;
}

- (void) loadView;
{
	NSAssert(nibName && nibBundle, @"default -loadView called and no nib name or bundle set");
	
	[nibBundle loadNibNamed:nibName owner:self options:nil];
	
	NSAssert(view, @"The view outlet must have been set by the nib");
	
	[self viewDidLoad];
}

- (void) viewDidLoad;
{}

- (void) didReceiveMemoryWarning;
{
	if (view && !view.superview) {
		self.view = nil;
		[self viewDidUnload];
	}
}

#pragma mark Managed outlets

- (void) clearOutlets;
{
	for (NSString* key in managedOutlets)
		[self setValue:nil forKey:key];
}

- (void) viewDidUnload;
{
	[self clearOutlets];
}

- (void) addManagedOutletKey:(NSString*) key;
{
	if (!managedOutlets)
		managedOutlets = [NSMutableSet new];
	
	[managedOutlets addObject:key];
}

- (void) addManagedOutletKeys:(NSString *)key, ...;
{
	[self addManagedOutletKey:key];
	
	va_list l;
	va_start(l, key);
	
	NSString* k = va_arg(l, NSString*);
	while (k) {
		[self addManagedOutletKey:k];
		k = va_arg(l, NSString*);
	}
	
	va_end(l);
}

@end
