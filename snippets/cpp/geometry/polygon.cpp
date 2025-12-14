ld polygon_area(vector<Pt> &p) {
    ld a = 0; int n = sza(p);
    for (int i = 0; i < n; i++)
        a += p[i].cross(p[(i + 1) % n]);
    return abs(a) / 2;
}
bool in_polygon(vector<Pt> &p, Pt q) {
    int n = sza(p), cnt = 0;
    for (int i = 0; i < n; i++) {
        Pt a = p[i], b = p[(i + 1) % n];
        if ((a.y <= q.y && q.y < b.y) || (b.y <= q.y && q.y < a.y))
            if (q.x < a.x + (b.x - a.x) * (q.y - a.y) / (b.y - a.y))
                cnt++;
    }
    return cnt & 1;
}
