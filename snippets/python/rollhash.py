class RollingHash:
    def __init__(self, s, base=911382629, mod=10**18 + 3):
        self.s = s
        self.n = len(s)
        self.base = base
        self.mod = mod
        self.powers = [1] * (self.n + 1)
        self.prefix_hashes = [0] * (self.n + 1)
        for i in range(1, self.n + 1):
            self.powers[i] = (self.powers[i - 1] * self.base) % self.mod
        for i in range(1, self.n + 1):
            self.prefix_hashes[i] = (self.prefix_hashes[i - 1] * self.base + ord(s[i - 1])) % self.mod
    def get_hash(self, l, r):
        return (self.prefix_hashes[r] - self.prefix_hashes[l] * self.powers[r - l]) % self.mod
