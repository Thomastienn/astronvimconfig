struct Seg {
    Pt a, b;
    Seg(Pt a = {}, Pt b = {}) : a(a), b(b) {}
    ld dist(Pt p) {
        Pt ab = b - a, ap = p - a, bp = p - b;
        if (ab.dot(ap) < 0) return ap.len();
        if (ab.dot(bp) > 0) return bp.len();
        return abs(ab.cross(ap)) / ab.len();
    }
    bool contains(Pt p) {
        return abs((b - a).cross(p - a)) < EPS && (p - a).dot(p - b) <= 0;
    }
};
