vi eulerian_path(vector<vpii> &g, int s = 0) {
    int n = sza(g); vector<vi> used(n);
    for (int u = 0; u < n; u++)
        used[u].resize(sza(g[u]));
    vi path; stack<int> st; st.push(s);
    while (!st.empty()) {
        int u = st.top();
        bool found = false;
        for (int i = 0; i < sza(g[u]); i++) {
            if (!used[u][i]) {
                used[u][i] = 1;
                st.push(g[u][i].f);
                found = true;
                break;
            }
        }
        if (!found) { path.pb(u); st.pop(); }
    }
    reverse(all(path));
    return path;
}
