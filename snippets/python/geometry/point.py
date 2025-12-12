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
