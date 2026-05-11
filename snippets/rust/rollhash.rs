// Single-mod rolling hash over the Mersenne prime 2^61 - 1.
// `get(l, r)` returns the hash of s[l..r] (half-open, like Python slicing).
struct RollHash {
    pw: Vec<u64>,
    h: Vec<u64>,
}
impl RollHash {
    const B: u64 = 131;
    const M: u64 = (1u64 << 61) - 1;

    fn new(s: &[u8]) -> Self {
        let n = s.len();
        let mut pw = vec![1u64; n + 1];
        let mut h = vec![0u64; n + 1];
        for i in 0..n {
            pw[i + 1] = Self::mul(pw[i], Self::B);
            h[i + 1] = Self::add(Self::mul(h[i], Self::B), s[i] as u64);
        }
        Self { pw, h }
    }
    fn mul(a: u64, b: u64) -> u64 {
        let prod = (a as u128) * (b as u128);
        let lo = (prod & ((1u128 << 61) - 1)) as u64;
        let hi = (prod >> 61) as u64;
        let v = lo + hi;
        if v >= Self::M { v - Self::M } else { v }
    }
    fn add(a: u64, b: u64) -> u64 {
        let v = a + b;
        if v >= Self::M { v - Self::M } else { v }
    }
    fn get(&self, l: usize, r: usize) -> u64 {
        let sub = Self::mul(self.h[l], self.pw[r - l]);
        Self::add(self.h[r], Self::M - sub)
    }
}
