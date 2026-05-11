type Mat = Vec<Vec<u64>>;

fn matmul(a: &Mat, b: &Mat, m: u64) -> Mat {
    let n = a.len();
    let k = b.len();
    let p = b[0].len();
    let mut c = vec![vec![0u64; p]; n];
    for i in 0..n {
        for kk in 0..k {
            if a[i][kk] == 0 { continue; }
            let aik = a[i][kk];
            for j in 0..p {
                c[i][j] = (c[i][j] + aik * b[kk][j]) % m;
            }
        }
    }
    c
}
fn matpow(mut a: Mat, mut n: u64, m: u64) -> Mat {
    let sz = a.len();
    let mut r: Mat = (0..sz).map(|i| {
        let mut row = vec![0u64; sz];
        row[i] = 1;
        row
    }).collect();
    while n > 0 {
        if n & 1 == 1 { r = matmul(&r, &a, m); }
        a = matmul(&a, &a, m);
        n >>= 1;
    }
    r
}
