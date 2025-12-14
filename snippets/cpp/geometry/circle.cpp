struct Circle {
    Pt c; ld r;
    Circle(Pt c = {}, ld r = 0) : c(c), r(r) {}
    bool contains(Pt p) { return (p - c).len() <= r + EPS; }
    ld area() { return PI * r * r; }
    ld circ() { return 2 * PI * r; }
};
pair<Pt, Pt> inter(Circle c, Line l) {
    Pt p = l.p, d = l.d.norm();
    ld h = d.cross(c.c - p), s = sqrt(c.r * c.r - h * h);
    Pt m = p + d * d.dot(c.c - p);
    return {m + d * s, m - d * s};
}
