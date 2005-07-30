/* 
   GormWindowAttributesInspector.m
   
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

/*
  July 2005 : Spilt inspector in separate classes.
  Always use ok: revert: methods
  Clean up
  Author : Fabien Vallon <fabien@sonappart.net>
*/

#include "GormWindowAttributesInspector.h"
#include "GormNSWindow.h"

#warning Should NOT call GormCore in Palette / Inspector !! ? 
#include <GormCore/GormDocument.h>
#include <GormCore/NSColorWell+GormExtensions.h>

#include <AppKit/NSNibLoading.h>



/*
  IBObjectAdditions category for NSPanel 
*/
@implementation	NSPanel (IBObjectAdditions)
- (NSString*) inspectorClassName
{
  return @"GormWindowAttributesInspector";
}
@end 

/*
  IBObjectAdditions category for NSWindow
*/
@implementation	NSWindow (IBObjectAdditions)
- (NSString*) inspectorClassName
{
  return @"GormWindowAttributesInspector";
}
@end

@implementation GormWindowAttributesInspector

- (id) init
{
  if ([super init] == nil)
    return nil;

  if ([NSBundle loadNibNamed: @"GormNSWindowInspector" owner: self] == NO)
    {
      NSLog(@"Could not gorm GormNSWindowInspector");
      return nil;
    }

  return self;
}

/* Commit changes that the user makes in the Attributes Inspector */
- (void) ok: (id)sender
{
  /* title */
  if (sender == titleForm)
    {
      [object setTitle: [[sender cellAtIndex: 0] stringValue] ]; 
    }
  /* backing Type */
  else if (sender == backingMatrix)
    {
      [object setBackingType: [[sender selectedCell] tag] ];
    }

  /* Masks */
  else if ( ( sender == miniaturizeButton ) ||
	    ( sender == closeButton ) ||
	    ( sender == resizeBarButton ) )
    {
      unsigned int newStyleMask;

      if ( [miniaturizeButton state] == NSOnState ) 
	newStyleMask |= NSMiniaturizableWindowMask;
      else 
	newStyleMask &= ~NSMiniaturizableWindowMask;

      if ( [closeButton state] == NSOnState ) 
	newStyleMask |= NSClosableWindowMask;
      else
	newStyleMask &= ~NSClosableWindowMask;

      if ( [resizeBarButton state] == NSOnState ) 
	newStyleMask |= NSResizableWindowMask;
      else
	newStyleMask &= ~NSResizableWindowMask;

      [object _setStyleMask: newStyleMask];            
#warning FIXME
      // FIXME: This doesn't refresh the window decoration. How to do that?
      // (currently needs manual hide/unhide to update decorations)
      [object display];
      
    }

  /* backgroundColor */
  else if (sender == colorWell)
    {
      [object setBackgroundColor: [colorWell color]];
    }

  
  /* release When Closed */
  else if ( sender == releaseButton ) 
    {
      [object _setReleasedWhenClosed:[releaseButton state]];
    }

  /* hide On Desactivate */
  else if ( sender == hideButton )  
    {
      [object setHidesOnDeactivate:[hideButton state]];
    }
  
  /* visible at launch time */
  else if ( sender == visibleButton ) 
    {
      GormDocument *doc = (GormDocument*)[(id<IB>)NSApp activeDocument];
      [doc setObject: object isVisibleAtLaunch: [visibleButton state]];
    }

  /* deferred */
  else if ( sender == deferredButton ) 
    {
      GormDocument *doc = (GormDocument*)[(id<IB>)NSApp activeDocument];
      [doc setObject: object isDeferred: [deferredButton state]];
    }
  
  /* One shot */
  else if ( sender == oneShotButton ) 
    {
      [object setOneShot:[oneShotButton state]];
    }

  /* Dynamic depth */
  else if ( sender == dynamicDepthButton ) 
    {
      [object setDynamicDepthLimit: [dynamicDepthButton state]];
    }

  /* icon name  */
  else if (sender == iconNameForm)
    {
      NSString *string = [[sender cellAtIndex: 0] stringValue];
      NSImage *image;
      /* the clearButton is disabled if the form is empty, enabled otherwise */
#warning probably not enough ( space ... )
      if ([string length] > 0)
	{
	  image = [NSImage imageNamed: string];
	  [object setMiniwindowImage: image];
	  [clearButton setEnabled:YES];
	}
      else
	{
	  // use the default, if the string is empty.
	  [object setMiniwindowImage: nil];
	  [clearButton setEnabled:NO];
	  
	}
    }
  /* clear the iconNameForm from clearButton */
  else if (sender == clearButton)
    {
      [[iconNameForm cellAtIndex: 0] setStringValue: nil];
      [object setMiniwindowImage: nil];
      [clearButton setEnabled:NO];
    }

  [super ok: sender];
}


/* Sync from object ( NSWindow ) changes to the inspector   */
- (void) revert:(id) sender
{
  GormDocument *doc;

  if ( object == nil ) 
    return;
    
  doc = (GormDocument*)[(id<IB>)NSApp activeDocument];

  /* Title */
  [[titleForm cellAtIndex: 0] setStringValue: [object title] ];
  
  /* Backing */
  [backingMatrix selectCellWithTag: [object backingType] ];

  /* Controls / Masks */
  [miniaturizeButton setState: ([object _styleMask] 
				& NSMiniaturizableWindowMask)];
  [closeButton setState:([object _styleMask] & NSClosableWindowMask)];
  [resizeBarButton setState:([object _styleMask] & NSResizableWindowMask)];

  /* Options */
  [releaseButton setState:[object _isReleasedWhenClosed]];
  [hideButton setState:[object hidesOnDeactivate]];
  [visibleButton setState:[doc objectIsVisibleAtLaunch: object]];
  [deferredButton setState:[doc objectIsDeferred: object]];
  [oneShotButton setState:[object isOneShot]];
  [dynamicDepthButton setState:[object hasDynamicDepthLimit]];
		 
   /* Icon Name */
  [[iconNameForm cellAtIndex: 0] setStringValue: 
				   [[object miniwindowImage] name]];
  
  /* the clearButton is disabled if the form is empty, enabled otherwise */
  if ( [[object miniwindowImage] name] == nil )
    [clearButton setEnabled:NO];
  else
    [clearButton setEnabled:YES];

  /* background color*/
  [colorWell setColorWithoutAction: [object backgroundColor]];
  
  [super revert:sender];
}


/* delegate method for changing the Window title */
- (void)controlTextDidChange:(NSNotification *)aNotification
{
  [self ok:[aNotification object]];
}

@end