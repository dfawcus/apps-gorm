/* GormViewEditor.h
 *
 * Copyright (C) 2002 Free Software Foundation, Inc.
 *
 * Author:	Pierre-Yves Rivaille <pyrivail@ens-lyon.fr>
 * Date:	2002
 * 
 * This file is part of GNUstep.
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */
#ifndef	INCLUDED_GormViewEditor_h
#define	INCLUDED_GormViewEditor_h

@class GormViewWithSubviewsEditor;
@class GormPlacementInfo;

@interface GormViewEditor : NSView <IBEditors>
{
  id<IBDocuments>	document;
  NSView		*_editedObject;
  BOOL                  activated;
  BOOL                  closed;
  GormViewWithSubviewsEditor        *parent;

}
- (BOOL) activate;
- (id) initWithObject: (id)anObject 
	   inDocument: (id<IBDocuments>)aDocument;
- (void) close;
- (void) deactivate;
- (id<IBDocuments>) document;
- (id) editedObject;
- (void) detachSubviews;
- (void) postDraw: (NSRect) rect;
- (id) parent;
@end

@interface GormViewEditor (EditingAdditions)
- (NSEvent *) editTextField: view withEvent: (NSEvent *)theEvent;
@end

@interface GormViewEditor (IntelligentPlacement)
- (GormPlacementInfo *) initializeResizingInFrame: (NSView *)view
						    withKnob: (IBKnobPosition) knob;
- (void) updateResizingWithFrame: (NSRect) frame
			andEvent: (NSEvent *)theEvent
		andPlacementInfo: (GormPlacementInfo*) gpi;
- (void) validateFrame: (NSRect) frame
	     withEvent: (NSEvent *) theEvent
      andPlacementInfo: (GormPlacementInfo*)gpi;
@end

@interface GormViewEditor (WindowAndRect)
/*
 * Pull the window object and it's rect.
 */
- (NSWindow *)windowAndRect: (NSRect *)prect
                  forObject: (id) object;
@end

#endif
