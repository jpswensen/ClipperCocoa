//
//  Path.m
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


#import "Path.h"
#import "Paths.h"

#ifdef HAVE_POLY2TRI
#import "poly2tri.h"
#endif

@implementation Path

@synthesize path=_path;

- (ClipperLib::Path*) pathPtr
{
    return &_path;
}


- (Path*) initWithPolygon:(NSMutableArray*)poly
{
    self = [super init];
    if (self) {
        for (int i = 0 ; i < [poly count] ; i++)
        {
            CGPoint pnt = [[poly objectAtIndex:i] CGPointValue];
            _path.push_back(ClipperLib::IntPoint(kClipperScale*pnt.x, kClipperScale*pnt.y));
        }
    }
    
    return self;

}

- (Path*) initWithPath:(ClipperLib::Path)path
{
    self = [super init];
    if (self) {
        _path = path;
    }
    
    return self;
}

- (unsigned long) count
{
    return _path.size();
}

- (CGPoint) pointAtIndex:(unsigned long)idx
{
    if (idx < [self count])
        return CGPointMake(_path[idx].X/kClipperScale, _path[idx].Y/kClipperScale);
    else
        return CGPointMake(0,0);
}

- (CGPoint) lastPoint
{
    int idx = (int)[self count]-1;
    if (idx >= 0)
        return CGPointMake(_path[idx].X/kClipperScale, _path[idx].Y/kClipperScale);
    else
        return CGPointMake(0,0);
}

- (void) addPoint:(CGPoint)pnt
{
    _path.push_back(ClipperLib::IntPoint(kClipperScale*pnt.x, kClipperScale*pnt.y));
}

- (void) addIntPoint:(ClipperLib::IntPoint)pnt
{
    _path.push_back(pnt);
}

- (void) insertPoint:(CGPoint)pnt atIndex:(int)idx
{
    ClipperLib::Path::iterator it = _path.begin() + idx;
    _path.insert(it, ClipperLib::IntPoint(kClipperScale*pnt.x, kClipperScale*pnt.y));
}


- (float) area
{
    return ClipperLib::Area(_path)/kClipperScale/kClipperScale;
}

- (Paths*) simplifyPolygon
{
    return [self simplifyPolygonWithFillType:ClipperLib::pftEvenOdd];
}

- (Paths*) simplifyPolygonWithFillType:(ClipperLib::PolyFillType)type
{
    Paths* retval = [[Paths alloc] init];
    ClipperLib::SimplifyPolygon(_path, *[retval pathsPtr],type);
    return retval;
}

- (void) reversePath
{
    ClipperLib::ReversePath(_path);
}

- (int) pointInPolygon:(CGPoint)pt;
{
    return ClipperLib::PointInPolygon(ClipperLib::IntPoint(kClipperScale*pt.x, kClipperScale*pt.y), _path);
}

- (int) intPointInPolygon:(ClipperLib::IntPoint)pt;
{
    return ClipperLib::PointInPolygon(pt, _path);
}

- (BOOL) orientation
{
    return ClipperLib::Orientation(_path);
}

- (Paths*) minkowskiSumWithPattern:(Path*)pattern pathIsClosed:(BOOL)pathIsClosed
{
    Paths* retval = [[Paths alloc] init];
    ClipperLib::MinkowskiSum(pattern.path, _path, *[retval pathsPtr], pathIsClosed);
    return retval;
}

- (Paths*) minkowskiDiffWithPoly:(Path*)poly2
{
    Paths* retval = [[Paths alloc] init];
    ClipperLib::MinkowskiDiff(_path, poly2.path, *[retval pathsPtr]);
    return retval;
}

- (Path*) cleanPolygon
{
    return [self cleanPolygonWithDistance:kDefaultCleanDistance];
}

- (Path*) cleanPolygonWithDistance:(double)distance
{
    Path* retval = [[Path alloc] init];
    ClipperLib::CleanPolygon(_path, *[retval pathPtr], distance*kClipperScale);
    return retval;
}

- (void) cleanSelf
{
    return [self cleanSelfWithDistance:kDefaultCleanDistance];
}

- (void) cleanSelfWithDistance:(double)distance
{
    ClipperLib::CleanPolygon(_path, distance*kClipperScale);
}

#ifdef HAVE_POLY2TRI
template <class C> void FreeClear( C & cntr ) {
    for ( typename C::iterator it = cntr.begin();
         it != cntr.end(); ++it ) {
        delete * it;
    }
    cntr.clear();
}


- (Paths*) triangulate
{
    // Use the poly2tri library to split up any concave pieces
    std::vector<p2t::Point*> polyline;
    for (int j = 0 ; j < _path.size() ; j++)
    {
        polyline.push_back(new p2t::Point(_path[j].X, _path[j].Y));
    }
    
    p2t::CDT* cdt = new p2t::CDT(polyline);
    cdt->Triangulate();
    std::vector<p2t::Triangle*> triangles;
    triangles = cdt->GetTriangles();
    
    Paths* retval = [[Paths alloc] init];
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

    
    return retval;
}
#endif


- (void) print
{
    printf("Orientation: %d  (", [self orientation]);
    for (int i = 0 ; i < _path.size() ; i++)
    {
        printf("(%f,%f)", (double)_path[i].X / (double)kClipperScale, (double)_path[i].Y / (double)kClipperScale);
        if (i<_path.size()-1)
            printf(",");
    }
    printf(")\n");
}

@end
