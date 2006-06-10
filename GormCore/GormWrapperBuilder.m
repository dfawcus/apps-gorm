/* GormWrapperBuilder
 *
 * These classes handle loading different formats into the
 * document's data structures.
 *
 * Copyright (C) 2006 Free Software Foundation, Inc.
 *
 * Author:      Gregory John Casamento <greg_casamento@yahoo.com>
 * Date:        2006
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
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02111 USA.
 */

#include <AppKit/NSFileWrapper.h>
#include <Foundation/NSString.h>
#include <Foundation/NSDictionary.h>
#include <GormCore/GormWrapperBuilder.h>
#include <GormCore/GormDocument.h>
#include <GormCore/GormPrivate.h>
#include <GormCore/GormSound.h>
#include <GormCore/GormImage.h>

static NSMutableDictionary *_wrapperBuilderMap = nil;
static GormWrapperBuilderFactory *_sharedWrapperBuilderFactory = nil;

@implementation GormWrapperBuilder
+ (NSString *) type
{
  [self subclassResponsibility: _cmd];
  return nil;
}

- (NSFileWrapper *) buildFileWrapperWithDocument: (GormDocument *)doc
{
  return [[NSFileWrapper alloc] initDirectoryWithFileWrappers: 
				  [self buildFileWrapperDictionaryWithDocument: doc]];
}

- (NSMutableDictionary *) buildFileWrapperDictionaryWithDocument: (GormDocument *)doc
{
  NSMutableDictionary *fileWrappers = [NSMutableDictionary dictionary];
  NSFileWrapper *scmDirWrapper = nil;

  // Assign document and don't retain... 
  document = doc; 

  //
  // Add the SCM wrapper to the wrapper, if it's present.
  //
  scmDirWrapper = [document scmWrapper];
  if(scmDirWrapper != nil)
    {
      NSString *name = [[scmDirWrapper filename] lastPathComponent];
      [fileWrappers setObject: scmDirWrapper forKey: name];
    }

  //
  // Copy resources into the new folder...
  // Gorm doesn't copy these into the folder right away since the folder may
  // not yet exist.   This allows the user to add/delete resources as they see fit
  // but only those which they end up with will actually be put into the wrapper
  // when the model/document is saved.
  //
  NSArray *resources = [[document sounds] arrayByAddingObjectsFromArray: 
					    [document images]];  
  id object = nil;
  NSEnumerator *en = [resources objectEnumerator];
  while ((object = [en nextObject]) != nil)
    {
      if([object isSystemResource] == NO)
	{
	  NSString *path = [object path];
	  NSString *resName = nil; 
	  NSData   *resData = nil;
	  NSFileWrapper *fileWrapper = nil;

	  if([object isInWrapper])
	    {
	      resName = [object filename];
	      resData = [object data];
	    }
	  else
	    {
	      resName = [path lastPathComponent];
	      resData = [NSData dataWithContentsOfFile: path];
	      [object setData: resData];
	      [object setInWrapper: YES];
	    }

	  fileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents: resData];
	  [fileWrappers setObject: fileWrapper forKey: resName];
	  RELEASE(fileWrapper);
	}
    }

  return fileWrappers;
}
@end

@implementation GormWrapperBuilderFactory 
+ (void) initialize
{
  NSArray *classes = GSObjCAllSubclassesOfClass([GormWrapperBuilder class]);
  NSEnumerator *en = [classes objectEnumerator];
  Class cls = nil;
  
  while((cls = [en nextObject]) != nil)
    {
      [self registerWrapperBuilderClass: cls];
    }
}

+ (void) registerWrapperBuilderClass: (Class)aClass
{
  if(_wrapperBuilderMap == nil)
    {
      _wrapperBuilderMap = [[NSMutableDictionary alloc] initWithCapacity: 5];
    }

  [_wrapperBuilderMap setObject: aClass forKey: (NSString *)[aClass type]];
}

+ (GormWrapperBuilderFactory *) sharedWrapperBuilderFactory
{
  if(_sharedWrapperBuilderFactory == nil)
    {
      _sharedWrapperBuilderFactory = [[self alloc] init];
    }
  return _sharedWrapperBuilderFactory;
}

- (id) init
{
  if((self = [super init]) != nil)
    {
      if(_sharedWrapperBuilderFactory == nil)
	{
	  _sharedWrapperBuilderFactory = self;
	}
    }
  return self;
}

- (id<GormWrapperBuilder>) wrapperBuilderForType: (NSString *) type
{
  Class cls = [_wrapperBuilderMap objectForKey: type];
  id<GormWrapperBuilder> obj = AUTORELEASE([[cls alloc] init]);
  return obj;
}
@end

