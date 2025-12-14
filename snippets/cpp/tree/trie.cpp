struct Trie {
    struct Node { int cnt; array<int, 26> to; };
    vector<Node> t; int sz;
    Trie() : t(1), sz(1) { t[0].to.fill(-1); }
    void insert(string &s) {
        int u = 0;
        for (char c : s) {
            int ch = c - 'a';
            if (t[u].to[ch] == -1) {
                t[u].to[ch] = sz++;
                t.pb({}); t.back().to.fill(-1);
            }
            u = t[u].to[ch];
        }
        t[u].cnt++;
    }
    bool search(string &s) {
        int u = 0;
        for (char c : s) {
            int ch = c - 'a';
            if (t[u].to[ch] == -1) return false;
            u = t[u].to[ch];
        }
        return t[u].cnt > 0;
    }
};
