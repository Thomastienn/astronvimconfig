// Requires the `point` and `line` snippets.
struct Circle { c: Pt, r: f64 }
impl Circle {
    fn new(c: Pt, r: f64) -> Self { Self { c, r } }
    fn contains(&self, p: Pt) -> bool { (p - self.c).len() <= self.r + 1e-9 }
    fn area(&self) -> f64 { std::f64::consts::PI * self.r * self.r }
    fn circ(&self) -> f64 { 2.0 * std::f64::consts::PI * self.r }
}
// Intersections of a circle with a line; returns None when the line misses the circle.
fn circle_line_inter(c: &Circle, l: &Line) -> Option<(Pt, Pt)> {
    let d = l.d.norm();
    let h = d.cross(c.c - l.p);
    let disc = c.r * c.r - h * h;
    if disc < 0.0 { return None; }
    let s = disc.sqrt();
    let m = l.p + d * d.dot(c.c - l.p);
    Some((m + d * s, m - d * s))
}
