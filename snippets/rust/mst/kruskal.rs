// Requires `DSU` from the `dsu` snippet. Edges are (weight, u, v).
fn kruskal(n: usize, mut edges: Vec<(i64, usize, usize)>) -> i64 {
    edges.sort();
    let mut dsu = DSU::new(n);
    let mut cost = 0i64;
    for (w, u, v) in edges {
        if dsu.unite(u, v) { cost += w; }
    }
    cost
}
