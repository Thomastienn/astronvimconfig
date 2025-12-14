ll digit_dp(ll num) {
    string s = to_string(num); int n = sza(s);
    map<tuple<int,int,int,int>, ll> dp;
    function<ll(int, bool, bool, int)> go = [&](int pos, bool tight, bool started, int state) {
        if (pos == n) return started ? 1LL : 0LL;
        auto key = make_tuple(pos, tight, started, state);
        if (dp.count(key)) return dp[key];
        int lim = tight ? s[pos] - '0' : 9;
        ll res = 0;
        for (int d = 0; d <= lim; d++) {
            bool new_tight = tight && (d == lim);
            bool new_started = started || (d != 0);
            int new_state = new_started ? state : state;
            res += go(pos + 1, new_tight, new_started, new_state);
        }
        return dp[key] = res;
    };
    return go(0, true, false, 0);
}
