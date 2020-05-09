using Distributed
using Plots

addprocs(4 -nprocs())
println("Using $(nprocs()) processes ")

@everywhere begin 
	include("introductionNonRivalEngine.jl")
end

@time retrialAvgViews = analysisFuncs.segregationDistributionAveraged(simFuncs.simulateIntroductionAveragescores
                        , 100, 5, 1000000, 5.0, 0.0, 0.01, 0.01, numTrials = 50)
scatter([x[1] for x in retrialAvgViews[1]], [x[2] for x in retrialAvgViews[1]])
