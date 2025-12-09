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
