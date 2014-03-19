//
//  PolyTree.m
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


#import "PolyTree.h"

#import "Path.h"
#import "Paths.h"
#import "PolyNode.h"

#ifdef HAVE_POLY2TRI
#import "poly2tri.h"
#endif

@implementation PolyTree

@synthesize tree=_tree;

- (void) clear
{
    _tree.Clear();
}

- (ClipperLib::PolyTree*) treePtr
{
    return &_tree;
}

- (PolyNode*) getFirst
{
    PolyNode* retval = [[PolyNode alloc] init];
    retval.node = _tree.GetFirst();
    return retval;
}

- (int) total
{
    return _tree.Total();
}

- (Paths*) toPaths
{
    Paths* retval = [[Paths alloc] init];
    ClipperLib::PolyTreeToPaths(_tree, *[retval pathsPtr]);
    return retval;
}

#ifdef HAVE_POLY2TRI
- (Paths*) triangulate
{
    Paths* retval = [[Paths alloc] init];
    
    //ClipperLib::PolyNode* polynode = _tree.GetFirst();
    p2t::CDT* cdt = NULL;
    
    for (int i = 0 ; i < _tree.ChildCount() ; i++)
    {
        // Create the polyline from this outer contour
        std::vector<p2t::Point*> polyline;
        for (int j = 0 ; j < _tree.Childs[i]->Contour.size() ; j++)
        {
            CGPoint pnt = CGPointMake( (double)_tree.Childs[i]->Contour[j].X, (double)_tree.Childs[i]->Contour[j].Y);
            polyline.push_back(new p2t::Point(pnt.x, pnt.y));
        }
        
        if (polyline.size()>0)
        {
            cdt = new p2t::CDT(polyline);
            // Create all the holes from the children of this polyline
            for (int j = 0 ; j < _tree.Childs[i]->ChildCount() ; j++)
            {
                std::vector<p2t::Point*> holeline;
                for (int k = 0; k < _tree.Childs[i]->Childs[j]->Contour.size() ; k++)
                {
                    CGPoint pnt = CGPointMake( (double)_tree.Childs[i]->Childs[j]->Contour[k].X, (double)_tree.Childs[i]->Childs[j]->Contour[k].Y);
                    holeline.push_back(new p2t::Point(pnt.x, pnt.y));
                }
                
                if (holeline.size() > 0)
                    cdt->AddHole(holeline);
            }
            
            cdt->Triangulate();
            std::vector<p2t::Triangle*> triangles;
            triangles = cdt->GetTriangles();
            
            //Paths* retval = [[Paths alloc] init];
            ClipperLib::Paths paths;
            for (p2t::Triangle* tri : triangles)
            {
                p2t::Point a = *(tri->GetPoint(0));
                p2t::Point b = *(tri->GetPoint(1));
                p2t::Point c = *(tri->GetPoint(2));
                
                Path* p = [[Path alloc] init];
                [p addIntPoint:ClipperLib::IntPoint(a.x, a.y)];
                [p addIntPoint:ClipperLib::IntPoint(b.x, b.y)];
                [p addIntPoint:ClipperLib::IntPoint(c.x, c.y)];
                
                [retval addPath:p];
            }
            
        }
        
        
    }
    
    return retval;
}
#endif

- (float) area
{
    float retval = 0.0;
    
    ClipperLib::PolyNode* polynode = _tree.GetFirst();
    while (polynode!=nil)
    {
        //do stuff with polynode here
        
        if (!polynode->IsHole())
        {
            retval += ClipperLib::Area(polynode->Contour);
        }
        else
        {
            retval -= ClipperLib::Area(polynode->Contour);
        }
        
        polynode = polynode->GetNext();
    }
    
    return retval;
}

@end
