from functools import lru_cache

def digit_dp(num):
    """
    Template for counting numbers in [0, num] satisfying some property.
    Modify the state and transitions based on the problem.
    """
    digits = list(map(int, str(num)))
    n = len(digits)
    
    @lru_cache(maxsize=None)
    def dp(pos, tight, started, state):
        """
        Args:
            pos: current digit position (0-indexed from left)
            tight: True if we're still bounded by num's digits
            started: True if we've placed a non-zero digit (handles leading zeros)
            state: problem-specific state (e.g., sum mod k, last digit, mask, etc.)
        Returns:
            count of valid numbers from this state
        """
        # Base case: processed all digits
        if pos == n:
            # Return 1 if valid, 0 otherwise
            # Modify based on problem (e.g., check if started, check state)
            return 1 if started else 0
        
        limit = digits[pos] if tight else 9
        result = 0
        
        for d in range(0, limit + 1):
            new_tight = tight and (d == limit)
            new_started = started or (d != 0)
            
            if not new_started:
                # Still leading zeros, state doesn't change
                result += dp(pos + 1, new_tight, False, state)
            else:
                # Update state based on problem
                new_state = state  # MODIFY THIS: e.g., (state + d) % k, state | (1 << d), etc.
                result += dp(pos + 1, new_tight, True, new_state)
        
        return result
    
    return dp(0, True, False, 0)  # Initial state: 0 or problem-specific


def count_in_range(lo, hi):
    """Count numbers in [lo, hi] satisfying the property."""
    if lo > 0:
        return digit_dp(hi) - digit_dp(lo - 1)
    return digit_dp(hi)
