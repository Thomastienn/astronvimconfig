struct Pt {
    ld x, y;
    Pt(ld x = 0, ld y = 0) : x(x), y(y) {}
    Pt operator+(Pt p) { return {x + p.x, y + p.y}; }
    Pt operator-(Pt p) { return {x - p.x, y - p.y}; }
    Pt operator*(ld t) { return {x * t, y * t}; }
    Pt operator/(ld t) { return {x / t, y / t}; }
    ld dot(Pt p) { return x * p.x + y * p.y; }
    ld cross(Pt p) { return x * p.y - y * p.x; }
    ld len2() { return x * x + y * y; }
    ld len() { return sqrt(len2()); }
    Pt norm() { return *this / len(); }
    Pt rot90() { return {-y, x}; }
};
