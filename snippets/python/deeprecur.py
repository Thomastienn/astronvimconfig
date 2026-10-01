from types import GeneratorType

def deep_recursion(f, stack=[]):
    """
    Deep recursion without RecursionError (recursive dfs on 2e5 nodes)
    Decorate, then `yield f(...)` for every recursive call and `yield x` instead of return
    Function must end with a yield
        @deep_recursion
        def dfs(u, p):
            for v in adj[u]:
                if v != p:
                    yield dfs(v, u)
            yield None
    """
    def wrapped(*args, **kwargs):
        if stack:
            return f(*args, **kwargs)
        to = f(*args, **kwargs)
        while True:
            if type(to) is GeneratorType:
                stack.append(to)
                to = next(to)
            else:
                stack.pop()
                if not stack:
                    break
                to = stack[-1].send(to)
        return to
    return wrapped
