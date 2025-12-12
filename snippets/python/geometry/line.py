from point import Point, sign

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
