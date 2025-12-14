struct Line {
    Pt p, d;
    Line(Pt p = {}, Pt d = {}) : p(p), d(d) {}
    Pt eval(ld t) { return p + d * t; }
    ld dist(Pt q) { return abs(d.cross(q - p)) / d.len(); }
};
bool inter(Line l1, Line l2, Pt &p) {
    ld det = l1.d.cross(l2.d);
    if (abs(det) < EPS) return false;
    ld t = (l2.p - l1.p).cross(l2.d) / det;
    p = l1.eval(t);
    return true;
}
