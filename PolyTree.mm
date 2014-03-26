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
template <class C> void FreeClear( C & cntr ) {
    for ( typename C::iterator it = cntr.begin();
         it != cntr.end(); ++it ) {
        delete * it;
    }
    cntr.clear();
}

- (void) triagulateNode:(ClipperLib::PolyNode*)node withTrianglePaths:(Paths**)retvalPtr
{
    Paths* retval = *retvalPtr;
    
    CGSize winSize = [[CCDirector sharedDirector] viewSize];
    
    if (node == NULL)
    {
        return;
    }
    else
    {
        if (!node->IsHole() && node->Contour.size() > 0)
        {
            // Triangulate this with all children holes as holes and add to retval
            // Create the polyline from this outer contour
            std::vector<p2t::Point*> polyline;
            
            //ClipperLib::CleanPolygons(tmpPaths,kClipperScale);
            //ClipperLib::SimplifyPolygons(tmpPaths);
            for (int j = 0 ; j < node->Contour.size() ; j++)
            {
                CGPoint pnt = CGPointMake( (double)node->Contour[j].X/(winSize.width*kClipperScale), (double)node->Contour[j].Y/(winSize.height*kClipperScale));
                polyline.push_back(new p2t::Point(pnt.x, pnt.y));
            }
            
            if (polyline.size()>0)
            {
                p2t::CDT* cdt  = new p2t::CDT(polyline);
                
                // Create all the holes from the children of this polyline
                std::vector< std::vector<p2t::Point*> > holelines;
                for (int j = 0 ; j < node->ChildCount() ; j++)
                {
                    if (node->Childs[j]->IsHole())
                    {
                        std::vector<p2t::Point*> holeline;
                        for (int k = 0; k < node->Childs[j]->Contour.size() ; k++)
                        {
                            CGPoint pnt = CGPointMake( (double)node->Childs[j]->Contour[k].X/(winSize.width*kClipperScale),
                                                       (double)node->Childs[j]->Contour[k].Y/(winSize.height*kClipperScale));
                            holeline.push_back(new p2t::Point(pnt.x, pnt.y));
                        }
                        
                        if (holeline.size() > 0)
                        {
                            holelines.push_back(holeline);
                            cdt->AddHole(holeline);
                        }
                        else
                        {
                            //NSLog(@"############# Child either empty or not a hole");
                        }
                    }
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
                    [p addIntPoint:ClipperLib::IntPoint(a.x*kClipperScale*winSize.width, a.y*kClipperScale*winSize.height)];
                    [p addIntPoint:ClipperLib::IntPoint(b.x*kClipperScale*winSize.width, b.y*kClipperScale*winSize.height)];
                    [p addIntPoint:ClipperLib::IntPoint(c.x*kClipperScale*winSize.width, c.y*kClipperScale*winSize.height)];
                    
                    [retval addPath:p];
                }
                
                // Cleanup
                delete cdt;
                
                // Free points
                FreeClear (polyline);
                
                for(int i = 0; i < holelines.size(); i++) {
                    std::vector<p2t::Point*> poly = holelines[i];
                    FreeClear(poly);
                }
                
                
            }
        }
        else
        {
            // Do nothing to triangulate
        }
        
        // Print out the orientation and all of the points in this node
        for (int i = 0 ; i < node->Childs.size() ; i++)
        {
            [self triagulateNode:node->Childs[i] withTrianglePaths:retvalPtr];
        }
    }
}

- (Paths*) triangulateDepthFirst
{
    Paths* retval = [[Paths alloc] init];

    for (int i = 0 ; i < _tree.Childs.size() ; i++)
    {
        [self triagulateNode:_tree.Childs[i] withTrianglePaths:&retval];
    }
    
    return retval;
}


- (Paths*) triangulate
{
    Paths* retval = [[Paths alloc] init];
    
    //ClipperLib::PolyNode* polynode = _tree.GetFirst();
    p2t::CDT* cdt = NULL;
    
    for (int i = 0 ; i < _tree.ChildCount() ; i++)
    {
        // Create the polyline from this outer contour
        std::vector<p2t::Point*> polyline;
        
        ClipperLib::Paths tmpPaths;
        tmpPaths.push_back(_tree.Childs[i]->Contour);
        ClipperLib::CleanPolygons(tmpPaths,sqrt(2)*kClipperScale);
        //ClipperLib::SimplifyPolygons(tmpPaths);
        
        ClipperLib::Path tmpPath = tmpPaths[0];
        for (int j = 0 ; j < tmpPath.size() ; j++)
        {
            CGPoint pnt = CGPointMake( (double)tmpPath[j].X, (double)tmpPath[j].Y);
            polyline.push_back(new p2t::Point(pnt.x, pnt.y));
        }

        if (polyline.size()>0)
        {
            cdt = new p2t::CDT(polyline);
            
            // Create all the holes from the children of this polyline
            std::vector< std::vector<p2t::Point*> > holelines;
            for (int j = 0 ; j < _tree.Childs[i]->ChildCount() ; j++)
            {
                std::vector<p2t::Point*> holeline;
                
                ClipperLib::Paths tmpPaths;
                tmpPaths.push_back(_tree.Childs[i]->Childs[j]->Contour);
                ClipperLib::CleanPolygons(tmpPaths,sqrt(2)*kClipperScale);
                //ClipperLib::SimplifyPolygons(tmpPaths);
                ClipperLib::Path tmpPath = tmpPaths[0];
                for (int k = 0; k < tmpPath.size() ; k++)
                {
                    CGPoint pnt = CGPointMake( (double)tmpPath[k].X, (double)tmpPath[k].Y);
                    holeline.push_back(new p2t::Point(pnt.x, pnt.y));
                }
                
                if (holeline.size() > 0 && _tree.Childs[i]->Childs[j]->IsHole())
                {
                    holelines.push_back(holeline);
                    cdt->AddHole(holeline);
                }
                else
                {
                    //NSLog(@"############# Child either empty or not a hole");
                }
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

            // Cleanup
            delete cdt;
            
            // Free points
            FreeClear (polyline);

            for(int i = 0; i < holelines.size(); i++) {
                std::vector<p2t::Point*> poly = holelines[i];
                FreeClear(poly);
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
            retval += ClipperLib::Area(polynode->Contour)/kClipperScale/kClipperScale;
        }
        else
        {
            retval += ClipperLib::Area(polynode->Contour)/kClipperScale/kClipperScale;
        }
        
        polynode = polynode->GetNext();
    }
    
    return retval;
}


- (void) print:(ClipperLib::PolyNode*)node
{
    static int indent = 0;
    
    if (node == NULL)
    {
        return;
    }
    else
    {
        // Print out the orientation and all of the points in this node
        for (int i = 0 ; i < indent ; i++)
            printf("  ");
        printf("Node -- Hole:%d\n", node->IsHole());
        
        for (int i = 0 ; i < indent ; i++)
            printf("  ");
        printf("(");
        for (int i = 0 ; i < node->Contour.size() ; i++)
        {
            printf("(%f,%f)", (double)node->Contour[i].X / (double)kClipperScale, (double)node->Contour[i].Y / (double)kClipperScale);
            if (i<node->Contour.size()-1)
                printf(",");
        }
        printf(")\n");
        
        
        indent++;
        
        for (int i = 0 ; i < node->Childs.size() ; i++)
        {
            [self print:node->Childs[i]];
        }
        
        indent--;
    }
    
}

- (void) print
{
    for (int i = 0 ; i < _tree.Childs.size() ; i++)
    {
        [self print:_tree.Childs[i]];
    }
}


@end
