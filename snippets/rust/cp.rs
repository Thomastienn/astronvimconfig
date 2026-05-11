#![allow(non_snake_case, unused_imports, unused_macros, dead_code)]

/*
* Problem: $(PROBLEM)
* Contest: $(CONTEST)
* Judge: $(JUDGE)
* URL: $(URL)
* Memory Limit: $(MEMLIM)
* Time Limit: $(TIMELIM)
* Start: $(DATE)
*/

use std::collections::*;
use std::io::{self, BufWriter, Read, StdoutLock, Write};

// Reads all of stdin once, then iterates over whitespace-separated tokens
// without allocating per-token. For interactive problems, swap to a BufRead-
// based scanner instead.
struct Sc {
    it: std::str::SplitAsciiWhitespace<'static>,
}
impl Sc {
    fn new() -> Self {
        let mut s = String::new();
        io::stdin().read_to_string(&mut s).expect("read failed");
        let s: &'static str = Box::leak(s.into_boxed_str());
        Self { it: s.split_ascii_whitespace() }
    }
    fn next<T: std::str::FromStr>(&mut self) -> T
    where <T as std::str::FromStr>::Err: std::fmt::Debug {
        self.it.next().expect("no more tokens").parse().expect("parse failed")
    }
    fn vec<T: std::str::FromStr>(&mut self, n: usize) -> Vec<T>
    where <T as std::str::FromStr>::Err: std::fmt::Debug {
        (0..n).map(|_| self.next()).collect()
    }
    fn chars(&mut self) -> Vec<char> { self.it.next().unwrap().chars().collect() }
    fn bytes(&mut self) -> Vec<u8> { self.it.next().unwrap().as_bytes().to_vec() }
}

#[cfg(debug_assertions)]
macro_rules! dbg2 {
    ($($x:expr),* $(,)?) => {{
        eprint!("[{}:{}]", file!(), line!());
        $( eprint!(" {}={:?}", stringify!($x), &$x); )*
        eprintln!();
    }};
}
#[cfg(not(debug_assertions))]
macro_rules! dbg2 { ($($_:tt)*) => {}; }

macro_rules! chmin { ($a:expr, $b:expr) => {{ let b = $b; if $a > b { $a = b; true } else { false } }}; }
macro_rules! chmax { ($a:expr, $b:expr) => {{ let b = $b; if $a < b { $a = b; true } else { false } }}; }

const INF: i64 = 1_000_000_000_000_000_000;
const MOD: u64 = 1_000_000_007;
const EPS: f64 = 1e-9;

fn solve(sc: &mut Sc, out: &mut BufWriter<StdoutLock>) {
}

fn main() {
    let mut sc = Sc::new();
    let stdout = io::stdout();
    let mut out = BufWriter::new(stdout.lock());
    let tc: usize = 1;
    // let tc: usize = sc.next();
    for _t in 1..=tc {
        // write!(out, "Case #{}: ", _t).unwrap();
        solve(&mut sc, &mut out);
    }
}
