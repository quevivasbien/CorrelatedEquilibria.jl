# CorrelEq

A package for finding correlated equilibria of normal form games.

## Setting up a game

### With two players

Create a game by specifying the matrix of payoffs. Here's a simple game of chicken:
```julia
game = Game([
    (0, 0) (7, 2);
    (2, 7) (6, 6)
])
```

You can also supply a separate payoff matrix for each player. The following defines the same game:
```julia
game = Game(
    [0 7; 2 6],
    [0 2; 7 6] 
)
```

You can provide a single matrix to define a zero-sum game:
```julia
game = Game([1 -1; -1 1])
```

### With n players

The game construction syntax generalizes to an arbitrary number of players -- you can create an n-player game by providing an n-dimensional array of n-tuples. For example, the following is a 3-player game with 2 actions for each player:
```julia
game = Game([
    (0, 1, 2) (3, 4, 5);
    (5, 4, 3) (2, 1, 0)
    ;;;
    (1, 2, 3) (4, 5, 6);
    (6, 5, 4) (3, 2, 1)
    ;;;
    (2, 3, 4) (5, 6, 7);
    (7, 6, 5) (4, 3, 2)
])
```
Providing a separate matrix for each player also works, with the following equivalent:
```julia
game = Game(
    [
        0 3; 5 2 ;;;
        1 4; 6 3 ;;;
        2 5; 7 4
    ],
    [
        1 4; 4 1 ;;;
        2 5; 5 2 ;;;
        3 6; 6 3
    ],
    [
        2 5; 5 2 ;;;
        3 6; 6 3 ;;;
        4 7; 7 4
    ]
)
```
In this case, you'll need to ensure that the matrices provided have the same dimensions, with the number of dimensions equal to the number of players.

## Solving

Solving works by defining a linear program, which is solved using [`JuMP.jl`](https://github.com/jump-dev/JuMP.jl).

Simply pass the game you want to solve to the `findeq` function. The result is an array of probabilities for the mixed-strategy equilibrium.
```julia
# using the chicken game from above
game = Game([
    (0, 0) (7, 2);
    (2, 7) (6, 6)
])
eq = findeq(game)
# should get eq == [0.0 0.25; 0.25 0.5]
```
By default, the result is the correlated equilibrium that maximizes total payoffs. If you want just any correlated equilibrium, you can set the keyword argument `best` to `false`, i.e., `findeq(game, best = false)`.
