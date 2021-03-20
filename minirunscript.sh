#!/bin/bash
echo "starting"
julia experiments/coopWins.jl -N 100 --judger EgoDefAccept --fitness classicalDefCost -k 5.0 --defcost 0.1
julia experiments/coopWins.jl -N 100 --judger EgoDefAccept --fitness classicalDefCost -k 5.0 --defcost 0.2
julia experiments/coopWins.jl -N 100 --judger EgoDefAccept --fitness classicalDefCost -k 5.0 --defcost 0.3
julia experiments/coopWins.jl -N 100 --judger EgoDefAccept --fitness classicalDefCost -k 5.0 --defcost 0.4
julia experiments/coopWins.jl -N 100 --judger EgoDefAccept --fitness classicalDefCost -k 5.0 --defcost 0.5