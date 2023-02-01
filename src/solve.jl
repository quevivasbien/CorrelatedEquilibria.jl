using JuMP
import HiGHS

# create constraints matrix for a 2-player game
function make_A(game::Game{2})
    (I, J) = size(game.payoffs)
    payoffs_1 = payoffs(game, 1)
    payoffs_2 = payoffs(game, 2)
    ncols = I * J
    nrows = J * (I - 1) + I * (J - 1)
    A = zeros(nrows, ncols)
    # iterate over all actions
    for i in 1:I, j in 1:J
        col = (j - 1) * I + i  # match column-major ordering
        # iterate over ways player 1 can defect
        row_offset = (i - 1) * (J - 1)
        for row in 1:(I - 1)
            k = row < i ? row : row + 1
            A[row + row_offset, col] = payoffs_1[i, j] - payoffs_1[k, j]
        end
        # iterate over ways player 2 can defect
        row_offset = (J + j - 1) * (I - 1)
        for row in 1:(J - 1)
            k = row < j ? row : row + 1
            A[row + row_offset, col] = payoffs_2[i, j] - payoffs_2[i, k]
        end
    end
    
    A
end

function make_A_p(payoffs::Array{Float64, N}, p::Int) where {N}
    # create portion of A corresponding to ways player p can defect
    IDX = size(payoffs)
    ncols = prod(IDX)
    row_multiplier = prod(IDX[1:p-1]) * prod(IDX[p+1:N])
    nrows = row_multiplier * (IDX[p] - 1)
    A_p = zeros(nrows, ncols)
    # iterate over all actions
    for (col, idx) in enumerate(CartesianIndices(payoffs))
        # iterate over ways player p can defect
        row_offset = (row_multiplier - 1) * (idx[p] - 1)
        for row in 1:(IDX[p] - 1)
            k = row < idx[p] ? row : row + 1
            idx_k = CartesianIndex((q == p ? k : idx[q] for q in 1:N)...)
            A_p[row + row_offset, col] = payoffs[idx] - payoffs[idx_k]
        end
    end

    A_p
end

function make_A(game::Game{N}) where {N}
    reduce(vcat, [make_A_p(payoffs(game, p), p) for p in 1:N])
end

# get total payoffs for all strategies
function flat_u(game::Game)
    tot_payoffs = map(sum, game.payoffs)
    vec(tot_payoffs)
end

# set up problem
# if best: max sum(u * x) s.t. A * x >= 0, sum(x) == 1, and x >= 0
# else: max sum(x) s.t. A * x >= 0, sum(x) <= 1, and x >= 0
function make_problem(game::Game; best = true)
    A = make_A(game)
    m = Model(HiGHS.Optimizer)
    @variable(m, x[1:size(A, 2)] .>= 0)
    @constraint(m, A * x .>= 0)
    if best
        @constraint(m, sum(x) == 1)
        @objective(m, Max, sum(flat_u(game) .* x))
    else
        @constraint(m, sum(x) <= 1)
        @objective(m, Max, sum(x))
    end
    m
end

# solve 2-player game
function correl_eq(game::Game; best = true, silent = true)
    m = make_problem(game; best)
    if silent
        set_silent(m)
    end
    optimize!(m)
    reshape(value.(m[:x]), size(game.payoffs))
end
