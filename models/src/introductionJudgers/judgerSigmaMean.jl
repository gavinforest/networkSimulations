module judgerSigmaMean

using LightGraphs
using StatsBase

export judgeSigmaMean


function sigma(x, k)
    return 1 / (1 + exp(-x * k))
end

function judgeSigmaMean(graph, types, fitnesses, a,b,c, k)
	introFitness = fitnesses[b]
	aAvgFitness = mean([fitnesses[j] for j in neighbors(graph,a)])
    cAvgFitness = mean([fitnesses[j] for j in neighbors(graph,c)])
    pConnect = sigma(introFitness - aAvgFitness,k) * sigma(introFitness - cAvgFitness,k)
    return pConnect
end

end
