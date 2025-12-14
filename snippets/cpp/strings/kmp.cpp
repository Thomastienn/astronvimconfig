vi kmp_table(string &s) {
    int n = sza(s); vi lps(n);
    for (int i = 1, j = 0; i < n; i++) {
        while (j && s[i] != s[j]) j = lps[j-1];
        if (s[i] == s[j]) lps[i] = ++j;
    }
    return lps;
}
vi kmp_search(string &txt, string &pat) {
    vi lps = kmp_table(pat), res;
    for (int i = 0, j = 0; i < sza(txt); i++) {
        while (j && txt[i] != pat[j]) j = lps[j-1];
        if (txt[i] == pat[j]) j++;
        if (j == sza(pat)) res.pb(i - j + 1), j = lps[j-1];
    }
    return res;
}
