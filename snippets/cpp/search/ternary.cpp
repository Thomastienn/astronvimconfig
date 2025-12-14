ld ternary_search(ld l, ld r, auto f) {
    const ld eps = 1e-9;
    while (r - l > eps) {
        ld m1 = l + (r - l) / 3;
        ld m2 = r - (r - l) / 3;
        if (f(m1) < f(m2)) r = m2;
        else l = m1;
    }
    return l;
}
