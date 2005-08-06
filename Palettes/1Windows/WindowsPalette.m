/* 
   main.m

   Copyright (C) 1999-2005 Free Software Foundation, Inc.

   Author:  Richard frith-Macdonald (richard@brainstorm.co.uk>
   Date: 1999
   
   This file is part of GNUstep.
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02111 USA.
*/

#include <InterfaceBuilder/IBApplicationAdditions.h>
#include <InterfaceBuilder/IBInspector.h>
#include <InterfaceBuilder/IBPalette.h>

#include <GormCore/GormDocument.h>
#include <GormCore/NSColorWell+GormExtensions.h>
#include <GNUstepGUI/GSNibTemplates.h>

#include "GormNSPanel.h"
#include "GormNSWindow.h"
#include "GormWindowSizeInspector.h"

@interface GormWindowMaker : NSObject <NSCoding>
{
}
@end

@implementation	GormWindowMaker
- (void) encodeWithCoder: (NSCoder*)aCoder
{
}

- (id) initWithCoder: (NSCoder*)aCoder
{
  id w;
  unsigned style = ( NSTitledWindowMask | NSClosableWindowMask
		     | NSResizableWindowMask | NSMiniaturizableWindowMask);
  NSRect        screenRect = [[NSScreen mainScreen] frame];
  float  x = (screenRect.size.width - 500)/2;
  float  y = (screenRect.size.height - 300)/2;
  NSRect        windowRect = NSMakeRect(x,y,500,300);

  w = [[GormNSWindow alloc] initWithContentRect: windowRect 
			    styleMask: style 
			    backing: NSBackingStoreRetained
			    defer: NO];

  [w setFrame: windowRect display: YES];
  [w setTitle: @"Window"];
  [w orderFront: self];
  RELEASE(self);
  return w;
}
@end

@interface GormPanelMaker : NSObject <NSCoding>
{
}
@end

@implementation	GormPanelMaker
- (void) encodeWithCoder: (NSCoder*)aCoder
{
}

- (id) initWithCoder: (NSCoder*)aCoder
{
  id		w;
  unsigned	style = NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask;
  NSRect        screenRect = [[NSScreen mainScreen] frame];
  float         
    x = (screenRect.size.width - 500)/2, 
    y = (screenRect.size.height - 300)/2;
  NSRect        windowRect = NSMakeRect(x,y,500,300);
  
  w = [[GormNSPanel alloc] initWithContentRect: windowRect 
			   styleMask: style 
			   backing: NSBackingStoreRetained
			   defer: NO];
  [w setFrame: windowRect display: YES];
  [w setTitle: @"Panel"];
  [w orderFront: self];
  RELEASE(self);
  return w;
}
@end

@interface WindowsPalette: IBPalette
{
}
@end

@implementation WindowsPalette
- (void) finishInstantiate
{
  NSView	*contents;
  id		w;
  id		v;
  NSBundle	*bundle = [NSBundle bundleForClass: [self class]];
  NSString	*path = [bundle pathForImageResource: @"WindowDrag"];
  NSImage	*dragImage = [[NSImage alloc] initWithContentsOfFile: path];

  RELEASE(originalWindow);
  originalWindow= [[NSWindow alloc] initWithContentRect: 
				      NSMakeRect(0, 0, 272, 192)
				    styleMask: NSBorderlessWindowMask 
				    backing: NSBackingStoreRetained
				    defer: NO];
  contents = [originalWindow contentView];

  w = [[GormWindowMaker alloc] init];
  v = [[NSButton alloc] initWithFrame: NSMakeRect(35, 60, 80, 64)];
  [v setBordered: NO];
  [v setImage: dragImage];
  [v setImagePosition: NSImageOverlaps];
  [v setTitle: @"Window"];
  [contents addSubview: v];
  [self associateObject: w
	type: IBWindowPboardType
	with: v];
  RELEASE(v);
  RELEASE(w);

  w = [[GormPanelMaker alloc] init];
  v = [[NSButton alloc] initWithFrame: NSMakeRect(155, 60, 80, 64)];
  [v setBordered: NO];
  [v setImage: dragImage];
  [v setImagePosition: NSImageOverlaps];
  [v setTitle: @"Panel"];
  [contents addSubview: v];
  [self associateObject: w
	type: IBWindowPboardType
	with: v];
  RELEASE(v);
  RELEASE(w);

  RELEASE(dragImage);
}
@end

@implementation NSWindow (GormPrivate)
+ (id) allocSubstitute
{
  return [GormNSWindow alloc];
}
@end

@implementation NSPanel (GormPrivate)
+ (id) allocSubstitute
{
  return [GormNSPanel alloc];
}
@end
