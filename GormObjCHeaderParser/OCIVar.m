/* OCHeaderParser.m
 *
 * Copyright (C) 1999 Free Software Foundation, Inc.
 *
 * Author:	Gregory John Casamento <greg_casamento@yahoo.com>
 * Date:	1999, 2002
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


#include <Foundation/Foundation.h>
#include <GormObjCHeaderParser/OCIVar.h>
#include <GormObjCHeaderParser/NSScanner+OCHeaderParser.h>

@implementation OCIVar

- (id) initWithString: (NSString *)string
{
  if((self = [super init]) != nil)
    {
      ASSIGN(ivarString, string);
    }
  return self;
}

- (void) dealloc
{
  RELEASE(ivarString);
  RELEASE(name);
  [super dealloc];
}

- (NSString *) name
{
  return name;
}

- (void) setName: (NSString *)aName
{
  ASSIGN(name,aName);
}

- (BOOL) isOutlet
{
  return isOutlet;
}

- (void) setIsOutlet: (BOOL)flag
{
  isOutlet = flag;
}

- (void) parse
{
  NSRange notFound = NSMakeRange(NSNotFound,0);
  NSCharacterSet *wsnl = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  NSScanner *scanner = [NSScanner scannerWithString: [ivarString stringByTrimmingCharactersInSet: wsnl]];
  NSRange range;
  NSString *tempName = nil;

  if(NSEqualRanges((range = [ivarString rangeOfString: @"IBOutlet"]),notFound) == NO &&
     range.location == 0)
    {
      [scanner scanUpToAndIncludingString: @"IBOutlet" intoString: NULL];  // return type
      [scanner scanCharactersFromSet: wsnl intoString: NULL];  
      [scanner scanUpToCharactersFromSet: wsnl intoString: NULL];  // typespec...
      [scanner scanCharactersFromSet: wsnl intoString: NULL];        
      [scanner scanUpToCharactersFromSet: wsnl intoString: &tempName]; // variable name...
      [self setIsOutlet: YES];
    }
  else if(NSEqualRanges((range = [ivarString rangeOfString: @"id"]),notFound) == NO &&
	  range.location == 0)
    {
      [scanner scanUpToCharactersFromSet: wsnl intoString: NULL];  // id
      [scanner scanCharactersFromSet: wsnl intoString: NULL];        
      [scanner scanUpToCharactersFromSet: wsnl intoString: &tempName];  // id
      [self setIsOutlet: YES];
    }
  else // for everything else...
    {
      [scanner scanUpToCharactersFromSet: wsnl intoString: NULL];  
      [scanner scanCharactersFromSet: wsnl intoString: NULL];        
      [scanner scanUpToCharactersFromSet: wsnl intoString: &tempName];        
    }

  // fix name...
  scanner = [NSScanner scannerWithString: tempName];
  [scanner setCharactersToBeSkipped: [NSCharacterSet characterSetWithCharactersInString: @"*"]];
  [scanner scanUpToCharactersFromSet: wsnl intoString: &name];
  RETAIN(name);
}
@end
