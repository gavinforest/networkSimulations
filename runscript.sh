#!/bin/bash
julia experiments/coopWins.jl -N 100 --judger ego --fitness classical -k 5.0
julia experiments/coopWins.jl -N 100 --judger ego --fitness divisible -k 5.0
julia experiments/coopWins.jl -N 100 --judger ego --fitness nonRival -k 5.0
julia experiments/coopWins.jl -N 100 --judger mean --fitness classical -k 5.0
julia experiments/coopWins.jl -N 100 --judger mean --fitness divisible -k 5.0
julia experiments/coopWins.jl -N 100 --judger mean --fitness nonRival -k 5.0
julia experiments/coopWins.jl -N 100 --judger ego --fitness classical -k 4.0
julia experiments/coopWins.jl -N 100 --judger ego --fitness divisible -k 4.0
julia experiments/coopWins.jl -N 100 --judger ego --fitness nonRival -k 4.0
julia experiments/coopWins.jl -N 100 --judger mean --fitness classical -k 4.0
julia experiments/coopWins.jl -N 100 --judger mean --fitness divisible -k 4.0
julia experiments/coopWins.jl -N 100 --judger mean --fitness nonRival -k 4.0
julia experiments/coopWins.jl -N 100 --judger ego --fitness classical -k 3.0
julia experiments/coopWins.jl -N 100 --judger ego --fitness divisible -k 3.0
julia experiments/coopWins.jl -N 100 --judger ego --fitness nonRival -k 3.0
julia experiments/coopWins.jl -N 100 --judger mean --fitness classical -k 3.0
julia experiments/coopWins.jl -N 100 --judger mean --fitness divisible -k 3.0
julia experiments/coopWins.jl -N 100 --judger mean --fitness nonRival -k 3.0
julia experiments/coopWins.jl -N 100 --judger ego --fitness classical -k 2.0
julia experiments/coopWins.jl -N 100 --judger ego --fitness divisible -k 2.0
julia experiments/coopWins.jl -N 100 --judger ego --fitness nonRival -k 2.0
julia experiments/coopWins.jl -N 100 --judger mean --fitness classical -k 2.0
julia experiments/coopWins.jl -N 100 --judger mean --fitness divisible -k 2.0
julia experiments/coopWins.jl -N 100 --judger mean --fitness nonRival -k 2.0
julia experiments/coopWins.jl -N 100 --judger ego --fitness classical -k 1.0
julia experiments/coopWins.jl -N 100 --judger ego --fitness divisible -k 1.0
julia experiments/coopWins.jl -N 100 --judger ego --fitness nonRival -k 1.0
julia experiments/coopWins.jl -N 100 --judger mean --fitness classical -k 1.0
julia experiments/coopWins.jl -N 100 --judger mean --fitness divisible -k 1.0
julia experiments/coopWins.jl -N 100 --judger mean --fitness nonRival -k 1.0
julia experiments/coopWins.jl -N 100 --judger EgoDefAccept --fitness classical -k 5.0
julia experiments/coopWins.jl -N 100 --judger EgoDefAccept --fitness divisible -k 5.0
julia experiments/coopWins.jl -N 100 --judger EgoDefAccept --fitness nonRival -k 5.0



