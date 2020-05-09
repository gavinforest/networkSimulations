module judgerSigmaEgo

using LightGraphs

export judgeSigmaEgo


function sigma(x,k)
    return 1 / (1 + exp(-k * x))
end

function judgeSigmaEgo(graph,types, fitnesses, a,b,c, k)
	introFitness = fitnesses[b]
    pConnect = sigma(introFitness - fitnesses[a], k) * sigma(introFitness - fitnesses[c], k)
    return pConnect
end

end