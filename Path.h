//
//  Path.h
//  An Objective-C wrapper for the Path object from the  Clipper library
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
//


//#define kClipperScale 100000.0f
//#define kClipperScale 10000000.0f
#define kClipperScale 1000000000.0f
#define kDefaultCleanDistance 1.415

@class Paths;

@interface Path : NSObject
{
    ClipperLib::Path _path;
}

@property (atomic,assign) ClipperLib::Path path;

- (Path*) initWithPath:(ClipperLib::Path)path;

- (ClipperLib::Path*) pathPtr;

- (Path*) initWithPolygon:(NSMutableArray*)poly;


- (unsigned long) count;
- (CGPoint) pointAtIndex:(unsigned long)idx;

- (CGPoint) lastPoint;

- (void) addPoint:(CGPoint)pnt;
- (void) addIntPoint:(ClipperLib::IntPoint)pnt;

- (void) insertPoint:(CGPoint)pnt atIndex:(int)idx;

- (float) area;

- (Paths*) simplifyPolygon;
- (Paths*) simplifyPolygonWithFillType:(ClipperLib::PolyFillType)type;
- (void) reversePath;
- (int) pointInPolygon:(CGPoint)pt;
- (int) intPointInPolygon:(ClipperLib::IntPoint)pt;
- (BOOL) orientation;

- (Paths*) minkowskiSumWithPattern:(Path*)pattern pathIsClosed:(BOOL)pathIsClosed;
- (Paths*) minkowskiDiffWithPoly:(Path*)poly2;

- (Path*) cleanPolygon;
- (void) cleanSelf;

- (Path*) cleanPolygonWithDistance:(double)distance;
- (void) cleanSelfWithDistance:(double)distance;

#ifdef HAVE_POLY2TRI
- (Paths*) triangulate;
#endif

- (void) print;

@end
