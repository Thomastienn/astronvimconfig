struct CHT {
    deque<pll> lines;
    bool bad(pll l1, pll l2, pll l3) {
        return (__int128)(l1.s - l2.s) * (l3.f - l2.f) >= (__int128)(l2.s - l3.s) * (l2.f - l1.f);
    }
    void add(ll m, ll b) {
        pll line = {m, b};
        while (sza(lines) >= 2 && bad(lines[sza(lines)-2], lines.back(), line))
            lines.ppb();
        lines.pb(line);
    }
    ll query(ll x) {
        while (sza(lines) >= 2 && lines[0].f * x + lines[0].s >= lines[1].f * x + lines[1].s)
            lines.pop_front();
        return lines[0].f * x + lines[0].s;
    }
};
