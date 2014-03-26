//
//  Paths.m
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


#import "Paths.h"

#import "Path.h"
#import "PolyTree.h"

@implementation Paths

@synthesize paths=_paths;

- (ClipperLib::Paths*) pathsPtr
{
    return &_paths;
}

- (Paths*) initWithPolygon:(NSMutableArray*)poly
{
    self = [super init];
    if (self) {
        ClipperLib::Path tmp;
        for (int i = 0 ; i < [poly count] ; i++)
        {
            CGPoint pnt = [[poly objectAtIndex:i] CGPointValue];
            tmp.push_back(ClipperLib::IntPoint(kClipperScale*pnt.x, kClipperScale*pnt.y));
        }
        _paths.push_back(tmp);
    }
    
    return self;
}

- (Paths*) initWithPolygons:(NSMutableArray*)polys
{
    self = [super init];
    if (self) {
        
        for (NSMutableArray* poly in polys)
        {
            ClipperLib::Path tmp;
            for (int i = 0 ; i < [poly count] ; i++)
            {
                CGPoint pnt = [[poly objectAtIndex:i] CGPointValue];
                tmp.push_back(ClipperLib::IntPoint(kClipperScale*pnt.x, kClipperScale*pnt.y));
            }
            _paths.push_back(tmp);
        }
    }
    
    return self;
}

- (Paths*) initWithPath:(Path*)path
{
    self = [super init];
    if (self) {
        _paths.push_back(path.path);
    }
    
    return self;
}

- (unsigned long) count
{
    return _paths.size();
}

- (Path*) pathAtIndex:(unsigned long)idx
{
    if (idx < [self count])
        return [[Path alloc] initWithPath:_paths[idx]];
    else
        return nil;
}

- (void) addPath:(Path*)path
{
    _paths.push_back(path.path);
}

- (Paths*) simplifyPolygons
{
    return [self simplifyPolygonsWithFillType:ClipperLib::pftEvenOdd];
}

- (void) simplifySelf
{
    [self simplifyPolygonsWithFillType:ClipperLib::pftEvenOdd];
}


- (Paths*) simplifyPolygonsWithFillType:(ClipperLib::PolyFillType)type
{
    Paths* retval = [[Paths alloc] init];
    ClipperLib::SimplifyPolygons(_paths, *[retval pathsPtr],type);
    return retval;
}

- (void) simplifySelfWithFillType:(ClipperLib::PolyFillType)type
{
    ClipperLib::SimplifyPolygons(_paths, type);
}


- (void) reversePaths
{
    ClipperLib::ReversePaths(_paths);
}

- (Paths*) offsetPathsWithDelta:(double)delta
{
    return [self offsetPathsWithDelta:delta jointType:ClipperLib::jtSquare endType:ClipperLib::etClosedPolygon];
}

- (Paths*) offsetPathsWithDelta:(double)delta jointType:(ClipperLib::JoinType)jointType
{
    return [self offsetPathsWithDelta:delta jointType:jointType endType:ClipperLib::etClosedPolygon];
}

- (Paths*) offsetPathsWithDelta:(double)delta jointType:(ClipperLib::JoinType)jointType endType:(ClipperLib::EndType)endType
{
    Paths* retval = [[Paths alloc] init];
    ClipperLib::ClipperOffset co;
    co.AddPaths(_paths, jointType, endType);
    co.Execute(*[retval pathsPtr], delta*kClipperScale);
    return retval;
}

- (Paths*) minkowskiSumWithPattern:(Path*)pattern pathFillType:(ClipperLib::PolyFillType)pathFillType pathIsClosed:(BOOL)pathIsClosed
{
    Paths* retval = [[Paths alloc] init];
    ClipperLib::MinkowskiSum(pattern.path, _paths, *[retval pathsPtr], pathFillType, pathIsClosed);
    return retval;
}

- (Paths*) cleanPolygons
{
    return [self cleanPolygonsWithDistance:kDefaultCleanDistance];
}

- (void) cleanSelf
{
    [self cleanSelfWithDistance:kDefaultCleanDistance];
}

- (Paths*) cleanPolygonsWithDistance:(double)distance
{
    Paths* retval = [[Paths alloc] init];
    ClipperLib::CleanPolygons(_paths, *[retval pathsPtr],distance*kClipperScale);
    return retval;
}

- (void) cleanSelfWithDistance:(double)distance
{
    ClipperLib::CleanPolygons(_paths,distance*kClipperScale);
}

- (NSMutableArray*) pathsArray
{
    NSMutableArray* retval = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < _paths.size() ; i++)
    {
        if (_paths[i].size() > 0)
        {
            NSMutableArray* tmp = [[NSMutableArray alloc] init];
            for (int j = 0 ; j < _paths[i].size() ; j++)
            {
                CGPoint tmpPnt = CGPointMake( (double)_paths[i][j].X / (double)kClipperScale , (double)_paths[i][j].Y / (double)kClipperScale);
                
                [tmp addObject:[NSValue valueWithCGPoint:tmpPnt]];
            }
            [retval addObject:tmp];
        }
    }
    
    return retval;
}

- (float) area
{
    float retval = 0.0;
    
    if ([self count] > 0)
    {
        BOOL holeOrientation = !ClipperLib::Orientation(_paths[0]);
        for (int i = 0 ; i < _paths.size() ; i++)
        {
            if (ClipperLib::Orientation(_paths[i]) != holeOrientation)
            {
                retval += ClipperLib::Area(_paths[i])/kClipperScale/kClipperScale;
            }
            else
            {
                retval += ClipperLib::Area(_paths[i])/kClipperScale/kClipperScale;
            }
            
            
        }
    }
    
    return retval;
}

- (void) print
{
    for (int i = 0 ; i < [self count] ; i++)
    {
        [[self pathAtIndex:i] print];
    }
}


@end
