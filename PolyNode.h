//
//  PolyNode.h
//  An Objective-C wrapper for the PolyNode object from the  Clipper library
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

@interface PolyNode : NSObject
{
    ClipperLib::PolyNode* _node;
}

@property (atomic,assign) ClipperLib::PolyNode* node;

- (PolyNode*) getNext;
- (int) childCount;
- (NSMutableArray*) childs;
- (Path*) contour;
- (BOOL) isHole;
- (BOOL) isOpen;
- (PolyNode*) parent;

@end
