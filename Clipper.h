//
//  Clipper.h
//  An Objective-C wrapper for the Clipper object from the  Clipper library
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
@class Paths;
@class PolyNode;
@class PolyTree;

@interface Clipper : NSObject
{
    // Instance of a clipper object
    ClipperLib::Clipper _clipper;
}

@property (nonatomic,assign) BOOL preserveCollinear;
@property (nonatomic,assign) BOOL reverseSolution;
@property (nonatomic,assign) BOOL strictlySimple;


- (void) addPath:(Path*)path polyType:(ClipperLib::PolyType)type closed:(BOOL)closed;
- (void) addPaths:(Paths*)path polyType:(ClipperLib::PolyType)type closed:(BOOL)closed;
- (void) clear;
- (ClipperLib::IntRect) getBounds;

- (Paths*) executeWithClipType:(ClipperLib::ClipType)clipType;
- (Paths*) executeWithClipType:(ClipperLib::ClipType)clipType subjFillType:(ClipperLib::PolyFillType)subjFillType clipFillType:(ClipperLib::PolyFillType)clipFillType;

- (PolyTree*) treeExecuteWithClipType:(ClipperLib::ClipType)clipType;
- (PolyTree*) treeExecuteWithClipType:(ClipperLib::ClipType)clipType subjFillType:(ClipperLib::PolyFillType)subjFillType clipFillType:(ClipperLib::PolyFillType)clipFillType;

+ (Paths*) unionPolygons:(Paths*)poly withPolygons:(Paths*)polyToUnionTo;
+ (Paths*) differencePolygons:(Paths*)poly fromPolygons:(Paths*)polyToDifferenceFrom;
+ (Paths*) intersectPolygons:(Paths*)polys1 withPolygons:(Paths*)polys2;
+ (Paths*) xorPolygons:(Paths*)polys1 withPolygons:(Paths*)polys2;

+ (PolyTree*) treeUnionPolygons:(Paths*)poly withPolygons:(Paths*)polyToUnionTo;
+ (PolyTree*) treeDifferencePolygons:(Paths*)poly fromPolygons:(Paths*)polyToDifferenceFrom;
+ (PolyTree*) treeIntersectPolygons:(Paths*)polys1 withPolygons:(Paths*)polys2;
+ (PolyTree*) treeXorPolygons:(Paths*)polys1 withPolygons:(Paths*)polys2;

@end
