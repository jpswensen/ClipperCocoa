//
//  Clipper.m
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


#import "Clipper.h"

#import "Path.h"
#import "Paths.h"
#import "PolyNode.h"
#import "PolyTree.h"


@implementation Clipper

- (void) setPreserveCollinear:(BOOL)preserveCollinear
{
    _clipper.PreserveCollinear(preserveCollinear);
}

- (void) setReverseSolution:(BOOL)reverseSolution
{
    _clipper.ReverseSolution(reverseSolution);
}

- (void) setStrictlySimple:(BOOL)strictlySimple
{
    _clipper.StrictlySimple(strictlySimple);
}

- (BOOL) preserverCollinear
{
    return _clipper.PreserveCollinear();
}

- (BOOL) reverseSolutions
{
    return _clipper.ReverseSolution();
}

- (BOOL) strictlySimple
{
    return _clipper.StrictlySimple();
}

- (void) addPath:(Path*)path polyType:(ClipperLib::PolyType)type closed:(BOOL)closed
{
    _clipper.AddPath(path.path, type, closed);
}

- (void) addPaths:(Paths*)paths polyType:(ClipperLib::PolyType)type closed:(BOOL)closed
{
    _clipper.AddPaths(paths.paths, type, closed);
}

- (void) clear
{
    _clipper.Clear();
}

- (ClipperLib::IntRect) getBounds
{
    return _clipper.GetBounds();
}

#pragma mark Clip routines with Paths output
- (Paths*) executeWithClipType:(ClipperLib::ClipType)clipType
{
    return [self executeWithClipType:clipType subjFillType:ClipperLib::pftEvenOdd clipFillType:ClipperLib::pftEvenOdd];
}

- (Paths*) executeWithClipType:(ClipperLib::ClipType)clipType subjFillType:(ClipperLib::PolyFillType)subjFillType clipFillType:(ClipperLib::PolyFillType)clipFillType
{
    Paths* retval = [[Paths alloc] init];
    _clipper.Execute(clipType, *[retval pathsPtr], subjFillType, clipFillType);
    return retval;
}

#pragma mark Clip routines with PolyTree output
- (PolyTree*) treeExecuteWithClipType:(ClipperLib::ClipType)clipType
{
    return [self treeExecuteWithClipType:clipType subjFillType:ClipperLib::pftEvenOdd clipFillType:ClipperLib::pftEvenOdd];
}

- (PolyTree*) treeExecuteWithClipType:(ClipperLib::ClipType)clipType subjFillType:(ClipperLib::PolyFillType)subjFillType clipFillType:(ClipperLib::PolyFillType)clipFillType
{
    PolyTree* retval = [[PolyTree alloc] init];
    _clipper.Execute(clipType,*[retval treePtr], subjFillType, clipFillType);
    return retval;

}


#pragma mark Polygon boolean routines with Paths output
+ (Paths*) unionPolygons:(Paths*)poly withPolygons:(Paths*)polyToUnionTo
{
    Clipper* c = [[Clipper alloc] init];
    c.strictlySimple = YES;
    [c addPaths:polyToUnionTo polyType:ClipperLib::ptSubject closed:YES];
    [c addPaths:poly polyType:ClipperLib::ptClip closed:YES];
    return [c executeWithClipType:ClipperLib::ctUnion subjFillType:ClipperLib::pftEvenOdd clipFillType:ClipperLib::pftEvenOdd];
}

+ (Paths*) differencePolygons:(Paths*)poly fromPolygons:(Paths*)polyToDifferenceFrom
{
    Clipper* c = [[Clipper alloc] init];
    c.strictlySimple = YES;
    [c addPaths:polyToDifferenceFrom polyType:ClipperLib::ptSubject closed:YES];
    [c addPaths:poly polyType:ClipperLib::ptClip closed:YES];
    return [c executeWithClipType:ClipperLib::ctDifference subjFillType:ClipperLib::pftEvenOdd clipFillType:ClipperLib::pftEvenOdd];
}

+ (Paths*) intersectPolygons:(Paths*)polys1 withPolygons:(Paths*)polys2
{
    Clipper* c = [[Clipper alloc] init];
    c.strictlySimple = YES;
    [c addPaths:polys1 polyType:ClipperLib::ptSubject closed:YES];
    [c addPaths:polys2 polyType:ClipperLib::ptClip closed:YES];
    return [c executeWithClipType:ClipperLib::ctIntersection subjFillType:ClipperLib::pftEvenOdd clipFillType:ClipperLib::pftEvenOdd];
}

+ (Paths*) xorPolygons:(Paths*)polys1 withPolygons:(Paths*)polys2
{
    Clipper* c = [[Clipper alloc] init];
    c.strictlySimple = YES;
    [c addPaths:polys1 polyType:ClipperLib::ptSubject closed:YES];
    [c addPaths:polys2 polyType:ClipperLib::ptClip closed:YES];
    return [c executeWithClipType:ClipperLib::ctXor subjFillType:ClipperLib::pftEvenOdd clipFillType:ClipperLib::pftEvenOdd];
}

#pragma mark Polygon boolean routines with PolyTree output
+ (PolyTree*) treeUnionPolygons:(Paths*)poly withPolygons:(Paths*)polyToUnionTo
{
    Clipper* c = [[Clipper alloc] init];
    c.strictlySimple = YES;
    [c addPaths:polyToUnionTo polyType:ClipperLib::ptSubject closed:YES];
    [c addPaths:poly polyType:ClipperLib::ptClip closed:YES];
    return [c treeExecuteWithClipType:ClipperLib::ctUnion subjFillType:ClipperLib::pftEvenOdd clipFillType:ClipperLib::pftEvenOdd];
}

+ (PolyTree*) treeDifferencePolygons:(Paths*)poly fromPolygons:(Paths*)polyToDifferenceFrom
{
    Clipper* c = [[Clipper alloc] init];
    c.strictlySimple = YES;
    [c addPaths:polyToDifferenceFrom polyType:ClipperLib::ptSubject closed:YES];
    [c addPaths:poly polyType:ClipperLib::ptClip closed:YES];
    return [c treeExecuteWithClipType:ClipperLib::ctDifference subjFillType:ClipperLib::pftEvenOdd clipFillType:ClipperLib::pftEvenOdd];
}

+ (PolyTree*) treeIntersectPolygons:(Paths*)polys1 withPolygons:(Paths*)polys2
{
    Clipper* c = [[Clipper alloc] init];
    c.strictlySimple = YES;
    [c addPaths:polys1 polyType:ClipperLib::ptSubject closed:YES];
    [c addPaths:polys2 polyType:ClipperLib::ptClip closed:YES];
    return [c treeExecuteWithClipType:ClipperLib::ctIntersection subjFillType:ClipperLib::pftEvenOdd clipFillType:ClipperLib::pftEvenOdd];
}

+ (PolyTree*) treeXorPolygons:(Paths*)polys1 withPolygons:(Paths*)polys2
{
    Clipper* c = [[Clipper alloc] init];
    c.strictlySimple = YES;
    [c addPaths:polys1 polyType:ClipperLib::ptSubject closed:YES];
    [c addPaths:polys2 polyType:ClipperLib::ptClip closed:YES];
    return [c treeExecuteWithClipType:ClipperLib::ctXor subjFillType:ClipperLib::pftEvenOdd clipFillType:ClipperLib::pftEvenOdd];
}

@end
