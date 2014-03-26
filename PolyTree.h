//
//  PolyTree.h
//  An Objective-C wrapper for the PolyTree object from the  Clipper library
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


@class Paths;
@class PolyNode;

@interface PolyTree : NSObject
{
    ClipperLib::PolyTree _tree;
}

@property (atomic,assign) ClipperLib::PolyTree tree;

- (ClipperLib::PolyTree*) treePtr;
- (void) clear;
- (PolyNode*) getFirst;
- (int) total;

- (Paths*) toPaths;

#ifdef HAVE_POLY2TRI
- (Paths*) triangulate;
- (Paths*) triangulateDepthFirst;
#endif

- (float) area;


- (void) print;


@end
