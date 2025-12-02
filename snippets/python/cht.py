from collections import deque

class CHT:
    """
    Convex Hull Trick for DP optimization
    Maintains lines y = mx + b, answers min queries
    
    Requirements:
    - Lines added in decreasing order of slope (m)
    - Queries in increasing order of x
    
    Time: O(1) amortized per operation
    
    Use case: dp[i] = min(dp[j] + cost(j,i)) where cost(j,i) = m[j] * x[i] + b[j]
    """
    def __init__(self):
        self.lines = deque()  # (m, b)
    
    def _bad(self, l1, l2, l3) -> bool:
        """Check if l2 is useless (dominated by l1 and l3)"""
        # (b1-b2)/(m2-m1) >= (b2-b3)/(m3-m2)
        # Cross multiply to avoid division
        return (l1[1] - l2[1]) * (l3[0] - l2[0]) >= (l2[1] - l3[1]) * (l2[0] - l1[0])
    
    def add(self, m: int, b: int) -> None:
        """Add line y = mx + b (must add in decreasing order of m)"""
        line = (m, b)
        while len(self.lines) >= 2 and self._bad(self.lines[-2], self.lines[-1], line):
            self.lines.pop()
        self.lines.append(line)
    
    def query(self, x: int) -> int:
        """Query minimum y at x (must query in increasing order of x)"""
        while len(self.lines) >= 2:
            m1, b1 = self.lines[0]
            m2, b2 = self.lines[1]
            if m1 * x + b1 >= m2 * x + b2:
                self.lines.popleft()
            else:
                break
        m, b = self.lines[0]
        return m * x + b
