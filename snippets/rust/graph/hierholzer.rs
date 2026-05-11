// Eulerian path/circuit via Hierholzer's algorithm.
// `g[u]` is a list of (v, edge_id) outgoing edges; for undirected graphs add the edge twice
// with the same `edge_id` so it can be marked used from either side.
fn eulerian_path(g: &Vec<Vec<(usize, usize)>>, s: usize, num_edges: usize) -> Vec<usize> {
    let n = g.len();
    let mut idx = vec![0usize; n];
    let mut used = vec![false; num_edges];
    let mut path = Vec::new();
    let mut st = vec![s];
    while let Some(&u) = st.last() {
        while idx[u] < g[u].len() && used[g[u][idx[u]].1] { idx[u] += 1; }
        if idx[u] == g[u].len() {
            path.push(u);
            st.pop();
        } else {
            let (v, eid) = g[u][idx[u]];
            used[eid] = true;
            idx[u] += 1;
            st.push(v);
        }
    }
    path.reverse();
    path
}
