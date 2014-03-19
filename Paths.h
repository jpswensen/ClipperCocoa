//
//  Paths.h
//  An Objective-C wrapper for the Paths object from the  Clipper library
//      (http://sourceforge.net/projects/polyclipping/)
//
//  Created by John Swensen on 3/18/14.
//  Copyright (c) 2014 John Swensen. All rights reserved.
//
//  License:
//  Use, modification & distribution is subject to Boost Software License Ver 1.
//  http://www.boost.org/LICENSE_1_0.txt
//


#import <Foundation/Foundation.h>

#import "clipper.hpp"

@class Path;

@interface Paths : NSObject
{
    ClipperLib::Paths _paths;
}

@property (atomic,assign) ClipperLib::Paths paths;


- (unsigned long) count;
- (Path*) pathAtIndex:(unsigned long)idx;
- (void) addPath:(Path*)path;

- (ClipperLib::Paths*) pathsPtr;

- (Paths*) initWithPolygon:(NSMutableArray*)poly;
- (Paths*) initWithPolygons:(NSMutableArray*)polys;
- (Paths*) initWithPath:(Path*)path;


- (Paths*) simplifyPolygons;
- (void) simplifySelf;

- (Paths*) simplifyPolygonsWithFillType:(ClipperLib::PolyFillType)type;
- (void) simplifySelfWithFillType:(ClipperLib::PolyFillType)type;

- (void) reversePaths;

- (Paths*) offsetPathsWithDelta:(double)delta ;
- (Paths*) offsetPathsWithDelta:(double)delta jointType:(ClipperLib::JoinType)jointType;
- (Paths*) offsetPathsWithDelta:(double)delta jointType:(ClipperLib::JoinType)jointType endType:(ClipperLib::EndType)endType;

- (Paths*) minkowskiSumWithPattern:(Path*)pattern pathFillType:(ClipperLib::PolyFillType)pathFillType pathIsClosed:(BOOL)pathIsClosed;

- (Paths*) cleanPolygons;
- (void) cleanSelf;

- (Paths*) cleanPolygonsWithDistance:(double)distance;
- (void) cleanSelfWithDistance:(double)distance;


// This will return an array of arrays of CGPoint values.
- (NSMutableArray*) pathsArray;

// This will return the area (subtracting the area of the holes)
- (float) area;

// This will return an NSMutableArray with and array of the three points defining the
//- (NSMutableArray*) triangulate;


@end
