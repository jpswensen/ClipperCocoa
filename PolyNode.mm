//
//  PolyNode.m
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


#import "PolyNode.h"

#import "Path.h"

@implementation PolyNode

@synthesize node=_node;

- (PolyNode*) getNext
{
    if (_node->GetNext() != NULL)
    {
        PolyNode* retval = [[PolyNode alloc] init];
        retval.node = _node->GetNext();
        return retval;
    }
    else
    {
        return nil;
    }
}

- (int) childCount
{
    return _node->ChildCount();
}

- (NSMutableArray*) childs
{
    
    
    NSMutableArray* retval = [[NSMutableArray alloc] init];
    std::vector<ClipperLib::PolyNode*> children = _node->Childs;
    for (int i = 0 ; i < children.size() ; i++)
    {
        PolyNode* tmp = [[PolyNode alloc] init];
        tmp.node = children[i];
        [retval addObject:tmp];
    }
    return retval;
}

- (Path*) contour
{
    Path* retval = [[Path alloc] init];
    retval.path = _node->Contour;
    return retval;
}

- (BOOL) isHole
{
    return _node->IsHole();
}

- (BOOL) isOpen
{
    return _node->IsOpen();
}

- (PolyNode*) parent
{
    PolyNode* retval = [[PolyNode alloc] init];
    retval.node = _node->Parent;
    return retval;
}

@end
