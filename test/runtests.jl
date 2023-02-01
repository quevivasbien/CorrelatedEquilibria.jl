using CorrelEq
using Test

@testset "CorrelEq.jl" begin
    # test zero-sum constructor
    @test begin
        game = zero_sum_game([-2 -1; 1 2])
        correl_eq(game, best = false, silent = false)
        true
    end
    # test matrix constructor
    @test begin
        game = Game(rand(2,2), rand(2,2))
        correl_eq(game, silent = false)
        true
    end
    # test chicken game
    @test begin
        game = Game([
            (0, 0) (7, 2);
            (2, 7) (6, 6)
        ])
        correl_eq(game, best = true, silent = false) == [0.0 0.25; 0.25 0.5]
    end
end
