struct Binom {
    fact: Vec<u64>,
    ifact: Vec<u64>,
    m: u64,
}
impl Binom {
    fn new(n: usize, m: u64) -> Self {
        let mut fact = vec![1u64; n + 1];
        for i in 1..=n { fact[i] = fact[i - 1] * i as u64 % m; }
        let mut ifact = vec![1u64; n + 1];
        ifact[n] = Self::pow(fact[n], m - 2, m);
        for i in (0..n).rev() { ifact[i] = ifact[i + 1] * (i + 1) as u64 % m; }
        Self { fact, ifact, m }
    }
    fn pow(mut a: u64, mut b: u64, m: u64) -> u64 {
        let mut r = 1u64 % m;
        while b > 0 {
            if b & 1 == 1 { r = r * a % m; }
            a = a * a % m;
            b >>= 1;
        }
        r
    }
    fn ncr(&self, n: usize, r: usize) -> u64 {
        if r > n { return 0; }
        self.fact[n] * self.ifact[r] % self.m * self.ifact[n - r] % self.m
    }
}
