from point import Point
from segment import Segment

class Polygon:
    def __init__(self, pts: list[Point]):
        self.pts = pts
        self.n = len(pts)
    
    def area(self) -> float:
        """Signed area (positive if ccw)"""
        total = 0.0
        for i in range(self.n):
            total += self.pts[i].cross(self.pts[(i + 1) % self.n])
        return total / 2
    
    def centroid(self) -> Point:
        a = self.area()
        cx = cy = 0.0
        for i in range(self.n):
            cross = self.pts[i].cross(self.pts[(i + 1) % self.n])
            cx += (self.pts[i].x + self.pts[(i + 1) % self.n].x) * cross
            cy += (self.pts[i].y + self.pts[(i + 1) % self.n].y) * cross
        return Point(cx / (6 * a), cy / (6 * a))
    
    def contains(self, p: Point) -> int:
        """1=inside, 0=boundary, -1=outside"""
        winding = 0
        for i in range(self.n):
            a, b = self.pts[i], self.pts[(i + 1) % self.n]
            if Segment(a, b).contains(p):
                return 0
            if a.y <= p.y:
                if b.y > p.y and Point.ccw(a, b, p) > 0:
                    winding += 1
            elif b.y <= p.y and Point.ccw(a, b, p) < 0:
                winding -= 1
        return 1 if winding != 0 else -1
    
    @staticmethod
    def convex_hull(pts: list[Point]) -> 'Polygon':
        """Andrew's monotone chain O(n log n)"""
        pts = sorted(pts)
        if len(pts) <= 1:
            return Polygon(pts)
        
        lower = []
        for p in pts:
            while len(lower) >= 2 and Point.ccw(lower[-2], lower[-1], p) <= 0:
                lower.pop()
            lower.append(p)
        
        upper = []
        for p in reversed(pts):
            while len(upper) >= 2 and Point.ccw(upper[-2], upper[-1], p) <= 0:
                upper.pop()
            upper.append(p)
        
        return Polygon(lower[:-1] + upper[:-1])
