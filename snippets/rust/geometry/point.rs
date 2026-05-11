#[derive(Clone, Copy, Debug, Default, PartialEq)]
struct Pt { x: f64, y: f64 }
impl Pt {
    fn new(x: f64, y: f64) -> Self { Self { x, y } }
    fn dot(self, p: Pt) -> f64 { self.x * p.x + self.y * p.y }
    fn cross(self, p: Pt) -> f64 { self.x * p.y - self.y * p.x }
    fn len2(self) -> f64 { self.x * self.x + self.y * self.y }
    fn len(self) -> f64 { self.len2().sqrt() }
    fn norm(self) -> Pt { let l = self.len(); Pt::new(self.x / l, self.y / l) }
    fn rot90(self) -> Pt { Pt::new(-self.y, self.x) }
}
impl std::ops::Add for Pt {
    type Output = Pt;
    fn add(self, p: Pt) -> Pt { Pt::new(self.x + p.x, self.y + p.y) }
}
impl std::ops::Sub for Pt {
    type Output = Pt;
    fn sub(self, p: Pt) -> Pt { Pt::new(self.x - p.x, self.y - p.y) }
}
impl std::ops::Mul<f64> for Pt {
    type Output = Pt;
    fn mul(self, t: f64) -> Pt { Pt::new(self.x * t, self.y * t) }
}
impl std::ops::Div<f64> for Pt {
    type Output = Pt;
    fn div(self, t: f64) -> Pt { Pt::new(self.x / t, self.y / t) }
}
