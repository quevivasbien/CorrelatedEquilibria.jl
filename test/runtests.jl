using CorrelEq
using Test

@testset "CorrelEq.jl" begin
    @test begin
        game = zero_sum_game([-2. -1.; 1. 2.])
        correl_eq(game, silent = false)
        true
    end
    @test begin
        game = Game(rand(2,2), rand(2,2))
        correl_eq(game, silent = false)
        true
    end
end
