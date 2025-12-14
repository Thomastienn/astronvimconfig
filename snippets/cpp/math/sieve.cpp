vi sieve(int n) {
    vector<bool> is_p(n + 1, true);
    is_p[0] = is_p[1] = false;
    for (int p = 2; p * p <= n; p++)
        if (is_p[p])
            for (int i = p * p; i <= n; i += p)
                is_p[i] = false;
    vi primes;
    for (int p = 2; p <= n; p++)
        if (is_p[p]) primes.pb(p);
    return primes;
}
