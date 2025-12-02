import math

EPS = 1e-9

def sign(x: float) -> int:
    if x > EPS: return 1
    if x < -EPS: return -1
    return 0

class Point:
    __slots__ = ['x', 'y']
    
    def __init__(self, x: float = 0, y: float = 0):
        self.x = x
        self.y = y
    
    def __add__(self, o: 'Point') -> 'Point':
        return Point(self.x + o.x, self.y + o.y)
    
    def __sub__(self, o: 'Point') -> 'Point':
        return Point(self.x - o.x, self.y - o.y)
    
    def __mul__(self, k: float) -> 'Point':
        return Point(self.x * k, self.y * k)
    
    def __truediv__(self, k: float) -> 'Point':
        return Point(self.x / k, self.y / k)
    
    def __eq__(self, o: 'Point') -> bool: # pyright: ignore
        return sign(self.x - o.x) == 0 and sign(self.y - o.y) == 0
    
    def __lt__(self, o: 'Point') -> bool:
        return (self.x, self.y) < (o.x, o.y) if sign(self.x - o.x) else self.y < o.y
    
    def __repr__(self) -> str:
        return f"({self.x}, {self.y})"
    
    def dot(self, o: 'Point') -> float:
        return self.x * o.x + self.y * o.y
    
    def cross(self, o: 'Point') -> float:
        return self.x * o.y - self.y * o.x
    
    def norm(self) -> float:
        return self.x * self.x + self.y * self.y
    
    def abs(self) -> float:
        return math.sqrt(self.norm())
    
    def unit(self) -> 'Point':
        return self / self.abs()
    
    def rotate(self, angle: float) -> 'Point':
        c, s = math.cos(angle), math.sin(angle)
        return Point(self.x * c - self.y * s, self.x * s + self.y * c)
    
    def rotate90(self) -> 'Point':
        return Point(-self.y, self.x)
    
    def dist(self, o: 'Point') -> float:
        return (self - o).abs()
    
    def dist_sq(self, o: 'Point') -> float:
        return (self - o).norm()
    
    @staticmethod
    def ccw(a: 'Point', b: 'Point', c: 'Point') -> int:
        """1=ccw, -1=cw, 0=collinear"""
        return sign((b - a).cross(c - a))

class Line:
    def __init__(self, p1: Point, p2: Point):
        self.p1 = p1
        self.p2 = p2
        self.d = p2 - p1
    
    def side(self, p: Point) -> int:
        """1=left, -1=right, 0=on"""
        return sign(self.d.cross(p - self.p1))
    
    def dist(self, p: Point) -> float:
        """Perpendicular distance from point to line"""
        return abs(self.d.cross(p - self.p1)) / self.d.abs()
    
    def project(self, p: Point) -> Point:
        t = (p - self.p1).dot(self.d) / self.d.norm()
        return self.p1 + self.d * t
    
    def reflect(self, p: Point) -> Point:
        return self.project(p) * 2 - p
    
    def intersection(self, other: 'Line') -> Point | None:
        cross = self.d.cross(other.d)
        if sign(cross) == 0:
            return None
        t = (other.p1 - self.p1).cross(other.d) / cross
        return self.p1 + self.d * t

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

class Circle:
    def __init__(self, center: Point, radius: float):
        self.c = center
        self.r = radius
    
    def contains(self, p: Point) -> bool:
        return sign(p.dist(self.c) - self.r) <= 0
    
    def area(self) -> float:
        return math.pi * self.r * self.r
    
    def circumference(self) -> float:
        return 2 * math.pi * self.r
    
    def intersection_area(self, other: 'Circle') -> float:
        d = self.c.dist(other.c)
        if sign(d - self.r - other.r) >= 0:
            return 0.0
        if sign(d + self.r - other.r) <= 0:
            return self.area()
        if sign(d + other.r - self.r) <= 0:
            return other.area()
        
        a1 = math.acos((self.r**2 + d**2 - other.r**2) / (2 * self.r * d)) * 2
        a2 = math.acos((other.r**2 + d**2 - self.r**2) / (2 * other.r * d)) * 2
        
        return (self.r**2 * (a1 - math.sin(a1)) + other.r**2 * (a2 - math.sin(a2))) / 2
