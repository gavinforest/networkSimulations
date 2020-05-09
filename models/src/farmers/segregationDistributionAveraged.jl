module segregationDistributionAveraged

root = "/Users/gavin/Documents/Stay_Loose/Research/Evolutionary_Dynamics/networkSimulations"
include("$root/models/src/analysis/analysis.jl")
using .analysis

using SharedArrays
using Distributed
using ProgressMeter
using DataFrames
@everywhere using LightGraphs
@everywhere using StatsBase

export segDistAvg

flatten(x) = [i for y in x for i in y]

function segDistAvg(simulator;  numTrials = 30, coopPropRange = [0.5], numSamples = 1)
    resultsArray = []
    samplesArray = []
    # proglabel = "Computing $(length(coopPropRange)) coop props..."
    @showprogress for coopP in coopPropRange
        results = SharedArray{Tuple{Float64,Float64, Float64}}(numTrials)
        sampleArr = SharedArray{Tuple{Int,Float64, Float64, Float64, Float64, Float64}}((numTrials, numSamples))
        @sync @distributed for n = 1:numTrials
            outgraph, outAgentScores, outAgentTypes, samples = simulator(coopProp=coopP)
            @assert ne(outgraph) == round(Int,nv(outgraph) * 2.5)

            p,u = getPdiffU(outgraph, outAgentScores, outAgentTypes, 0.01, coopP)
            f,u = getFdiffU(outgraph, outAgentScores, outAgentTypes, coopP)
            results[n] = (f, p, u)
            sampleArr[n,:] = samples
        end
        push!(resultsArray, sdata(results))
        push!(samplesArray, sdata(sampleArr))
    end


    flatArray = flatten(resultsArray)

    coopProps = []
    for x in coopPropRange
        push!(coopProps, [x for _ in 1:numTrials])
    end
    seriesDf = DataFrame(id = Int[], n = Int[], fcoop = Float64[], fdef = Float64[], 
                        pcoop = Float64[], pdef = Float64[], u = Float64[])
    for i in 1:length(coopPropRange)
        coop = coopPropRange[i]
        seriesArray = samplesArray[i]
        for j in 1:numTrials
            series = seriesArray[j,:]
            id = i * numTrials + j
            for s in series
                push!(seriesDf, (id, s...))
            end
        end
    end

    coopProps = flatten(coopProps)
    resDf = DataFrame(coop = coopProps, fitDiff = [x[1] for x in flatArray], payoffDiff = [x[2] for x in flatArray], u = [x[3] for x in flatArray])

    return resDf, seriesDf
end

end