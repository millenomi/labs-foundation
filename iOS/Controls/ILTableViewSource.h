//
//  ILTableViewSource.h
//  Controls
//
//  Created by ∞ on 09/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (ILTableViewAdditions)

/**
 This property can be used to specify an action on each cell to be executed when the cell is selected.
 
 The action is not executed automatically by the cell; a delegate must execute it when needed. Note however that ILTableViewSource executes this block if non-nil as part of its UITableViewDelegate implementation.
 */
@property(copy, nonatomic) void (^didSelect)();

@end


@class ILTableViewSource, ILTableViewSection;
@protocol ILTableViewSection, ILTableViewSectionMutationDelegate;

/**
 
 A mutation delegate is associated to ILTableViewSection protocol objects when the section is added to a table view source (a ILTableViewSource object). This delegate must be informed whenever the contents of a section change, in order to keep the associated table view consistent.
 
 */
@protocol ILTableViewSectionMutationDelegate <NSObject>

/**
 This method must be called whenever the contents of this section change in a way that is cannot be described using the other methods in this protocol.
 
 Calling this method will reload the section entirely. You should strive to use the other methods in this protocol whenever possible to ensure better efficiency.
 
 @param section The section whose content has changed.
 */
- (void) sectionDidChange:(id <ILTableViewSection>) section;

/**
 This method should be called whenever one or more rows of a section change in a way that requires reloading their associated cells.

 @param section The section whose content has changed.
 @param indexes The indexes whose content have been replaced.
 */
- (void) section:(id <ILTableViewSection>) section didReplaceRowsAtIndexes:(NSIndexSet*) indexes;

/**
 This method should be called whenever one or more rows of a section are removed.

 @param section The section whose content has changed.
 @param indexes The indexes whose content have been deleted.
 */
- (void) section:(id <ILTableViewSection>) section didDeleteRowsAtIndexes:(NSIndexSet*) indexes;

/**
 This method should be called whenever one or more rows of a section are inserted.
 
 @param section The section whose content has changed.
 @param indexes The indexes whose content have been inserted.
 */
- (void) section:(id <ILTableViewSection>) section didInsertRowsAtIndexes:(NSIndexSet*) indexes;

@end

/**
 An object conforming to this protocol handles all activity for a particular table view section. A ILTableViewSource manages a collection of these objects to define the contents of the table view it works as a source for.
 */
@protocol ILTableViewSection <NSObject>

/**
 Returns the count of rows in this section.
 */
- (NSUInteger) countOfRows;

/**
 Returns a cell for the given row in this section. You can use the table view's cell dequeuing facility to obtain an existing cell, and/or create or obtain a new one if required.
 
 You must never reuse a cell for two different rows, except if you dequeue it from the table view.
 
 @param index The index of the row to return indexes for.
 @param tv The table view that will display the returned cell.
 */
- (UITableViewCell*) cellForRowAtIndex:(NSUInteger) index inTableView:(UITableView*) tv;

/**
 Returns the title of this section. If nil, no header is shown for this section.
 */
- (NSString*) title;

/**
 Sets or removes the mutation delegate for this section. While set, this object must be informed of all changes that occur to the contents of this section. See the ILTableViewSectionMutationDelegate protocol for details.
 
 Since this object is a delegate, it should not be retained. It is guaranteed to remain valid for as long as it's set. This method will be called with a nil argument at appropriate times to remove the reference to the delegate when it's no longer valid.
 
 @param d The mutation delegate.
 */
- (void) setMutationDelegate:(id <ILTableViewSectionMutationDelegate>) d;

@end

// -----------------------------

/**
 A table view source is used as a delegate and data source to a table view to make providing data to that view easier.
 
 You can create a source using the tableViewSource or init methods. The source must then be associated to a table view using the tableView property. Each source can only be associated to a single table view, and becomes that view's delegate and data source when associated (see the tableView property for details).
 
 Sources manage a set of section objects (instances conforming to the ILTableViewSection protocol). You can edit the contents of a source by mutating the array returned by the mutableSection property; the table view will be kept in sync with the contents of this array.
 
 */
@interface ILTableViewSource : NSObject <UITableViewDelegate, UITableViewDataSource> {
@private
	NSMutableArray* _sectionsArray;
}

/**
 Creates a new table view source.
 */
+ tableViewSource;

/**
 The table view this source is associated with. You can change table views at will, but only one table view can be associated with a source at any one time.
 
 Setting a table view through this property may change the delegate and data source of the table; in particular, any of these properties that is set to nil is changed to point to this object instead. When a table view is removed from this property, or this object is deallocated, any of those properties associated with this object are set back to nil. You can use this behavior to associate a different delegate or data source to customize any desired behavior, but you should ultimately call out to the implementations provided by this source for it to function correctly.
 */
@property(retain, nonatomic) UITableView* tableView;

/**
 Sets this object as delegate and data source for the table view set in the tableView property. You can use this method to override the default behavior of the tableView property, which avoids overriding any present delegate or data source.
 */
- (void) setAsDelegateAndDataSourceForTableView;

/**
 Provides an array containing the sections for this table view. To edit the content of this source, use the mutableSections property; any changes to that array are immediately reflected by this property.
 */
@property(copy, nonatomic) NSArray* sections;

/**
 This is a mutable array containing the section objects that make up the contents of this source. Changing the returned array also changes the table view's display accordingly. This array can only contain objects conforming to the ILTableViewSection protocol.
 */
@property(readonly, nonatomic) NSMutableArray* mutableSections;

@end

// -----------------------------

typedef UITableViewCell* (^ILTableViewSectionCellForRowObject)(id, NSInteger, UITableView*);

/**
 This class implements a table view section object that can be used alongside a ILTableViewSource object; this section keeps its content in an array much like the sections array of a table view source.
 
 
 */
@interface ILTableViewSection : NSObject <ILTableViewSection> {
@private
	NSMutableArray* _rowsArray;
}

/**
 Creates a new table view section.
 */
+ tableViewSection;

/**
 Sets the title displayed in the header of this section. If nil, no header is displayed.
 */
@property(copy, nonatomic) NSString* title;

/**
 Provides an array containing the rows for this section. To edit the content of this section, use the mutableRows property; any changes to that array are immediately reflected by this property.
 */
@property(copy, nonatomic) NSArray* rows;

/**
 This is a mutable array containing the row objects that make up the contents of this section. Changing the returned array also changes the table view's display accordingly.
 
 This array can contain objects of any class; however, if any of the objects are not UITableViewCell (or subclasses thereof), you must set the cellForRowObject property to provide cells for these objects.
 */
@property(readonly, nonatomic) NSMutableArray* mutableRows;

/**
 This property holds the mutation delegate that is associated to this object by the table view source. See the ILTableViewSectionMutationDelegate protocol for more information.
 */
@property(assign, nonatomic) id <ILTableViewSectionMutationDelegate> mutationDelegate;

/**
 This property holds a block that is called to produce cells for any row object that is not itself a UITableViewCell. This block is passed the object for the row, its index and the table view that will be used to display the cell, and it can produce a cell and/or dequeue one for reuse from the table view.
 
 This method must return different views for different cell indexes, with the only exception of cells dequeued from the passed table view.
 */
@property(copy, nonatomic) UITableViewCell* (^cellForRowObject)(id object, NSInteger rowIndex, UITableView* tableView);

@end
