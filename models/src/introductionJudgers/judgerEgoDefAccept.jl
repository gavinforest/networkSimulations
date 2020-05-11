module judgerEgoDefAccept

using LightGraphs

export judgeEgoDefAccept


function sigma(x,k)
    return 1 / (1 + exp(-k * x))
end

function connectProbability(graph,types,fitnesses, a,b,c,k)
	if (types[a] == 0)
		return 1.0
	else
		return sigma(fitnesses[b] - fitnesses[a],k)
	end
end


function judgeEgoDefAccept(graph, types, fitnesses, a,b,c, k)
	pa = connectProbability(graph,types,fitnesses,a,b,c,k)
	pb = connectProbability(graph,types,fitnesses,c,b,a,k)	
	return pa * pb
end

end