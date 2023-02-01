# an N-player normal form game
struct Game{N}
    payoffs::Array{NTuple{N, Float64}, N}
end

function Game(payoffs::Array{T}) where {T <: Tuple}
    n = length(payoffs[1])
    Game(map((x) -> convert(NTuple{n, Float64}, x), payoffs))
end

function Game(payoffs::Array{T}...) where T <: Number
    Game(map((x) -> convert(NTuple{length(payoffs), Float64}, x), zip(payoffs...)))
end

# create a 2-player zero-sum game
function zero_sum_game(payoffs::Array{Float64, 2})
    Game{2}(map((x) -> (x, -x), payoffs))
end

function payoffs(game::Game, player::Int)
    map((x) -> x[player], game.payoffs)
end

function payoffs(game::Game, actions::Vararg{Int, N}) where N
    game.payoffs[actions...]
end
