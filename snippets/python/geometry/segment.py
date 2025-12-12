from point import Point, sign

class Segment:
    def __init__(self, a: Point, b: Point):
        self.a = a
        self.b = b
    
    def contains(self, p: Point) -> bool:
        """Check if point is on segment"""
        return (sign((self.a - p).cross(self.b - p)) == 0 and
                sign((self.a - p).dot(self.b - p)) <= 0)
    
    def dist(self, p: Point) -> float:
        """Distance from point to segment"""
        if self.a == self.b:
            return p.dist(self.a)
        d = self.b - self.a
        t = max(0.0, min(1.0, (p - self.a).dot(d) / d.norm()))
        return p.dist(self.a + d * t)
    
    def intersects(self, other: 'Segment') -> bool:
        """Check if two segments intersect"""
        a, b, c, d = self.a, self.b, other.a, other.b
        d1 = Point.ccw(c, d, a)
        d2 = Point.ccw(c, d, b)
        d3 = Point.ccw(a, b, c)
        d4 = Point.ccw(a, b, d)
        
        if d1 * d2 < 0 and d3 * d4 < 0:
            return True
        if d1 == 0 and other.contains(a): return True
        if d2 == 0 and other.contains(b): return True
        if d3 == 0 and self.contains(c): return True
        if d4 == 0 and self.contains(d): return True
        return False
