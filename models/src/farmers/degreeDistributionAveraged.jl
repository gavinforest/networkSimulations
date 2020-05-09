module degreeDistributionAveraged

root = "/Users/gavin/Documents/Stay_Loose/Research/Evolutionary_Dynamics/networkSimulations"
include("$root/models/src/analysis/analysis.jl")
using .analysis

using SharedArrays
using Distributed
using ProgressMeter
using DataFrames
@everywhere using LightGraphs
@everywhere using StatsBase

export degDistAvg

flatten(x) = [i for y in x for i in y]

function degDistAvg(simulator;  numTrials = 30, coopPropRange = [0.5], N = 100)
    resultsArray = []
    # @showprogress for coopP in coopPropRange
    results = SharedArray{Tuple{Int64, Int64, Int64, Int64}}(numTrials * N)
    coopP = coopPropRange[1]
    @sync @distributed for n = 1:numTrials
        # println("Starting trial")
        outgraph, outAgentScores, outAgentTypes, samples = simulator(coopProp=coopP)
        # println("Generated graph")
        @show ne(outgraph)
        @show nv(outgraph)
        k = round(Int,sqrt(nv(outgraph))/2)
        @assert abs(ne(outgraph) - floor(Int, nv(outgraph) * k/2)) < 1
        for v in 1:N
            tDegree = degree(outgraph, v)
            cDegree = length([x for x in neighbors(outgraph,v) if outAgentTypes[x] == 1])
            dDegree = tDegree - cDegree
            results[v + (n-1) * numTrials] = (tDegree, cDegree, dDegree, (n -1) * N + v)
        end
        println("finished trial")
    end
    push!(resultsArray, sdata(results))
    # end


    flatArray = flatten(resultsArray)

    coopProps = []
    for x in coopPropRange
        push!(coopProps, fill(x, numTrials * N))
    end
    

    coopProps = flatten(coopProps)
    resDf = DataFrame(coop = coopProps)
    resDf.degree = [x[1] for x in flatArray]
    resDf.cDegree = [x[2] for x in flatArray]
    resDf.dDegree = [x[3] for x in flatArray]
    resDf.vId = [x[4] for x in flatArray]

    return resDf
end

end