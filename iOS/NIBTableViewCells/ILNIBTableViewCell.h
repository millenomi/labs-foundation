//
//  ILNIBTableViewCell.h
//  NIBTableViewCells
//
//  Created by ∞ on 05/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ILNIBTableViewCell : UITableViewCell {}

+ reuseIdentifier; // the default reuse identifier for reusable instances of this class, used by initReusable:. 

- (id) initWithNibName:(NSString*) name bundle:(NSBundle*) bundle reuseIdentifier:(NSString*) reuseIdent;
- (id) initReusable:(BOOL) allowReuse; // convenience; reuse ID is nil or same as class name (from [[self class] reuseIdentifier]), NIB name is class name + '.nib', bundle is bundle for this class.
- (id) init; // same as initReusable:YES.

@property(retain) IBOutlet UIView* cellContentView;

@end
