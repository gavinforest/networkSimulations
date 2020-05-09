module judgerEgoDefectorVis

using LightGraphs

export judgeEgoDefVis, makeJudgeEgoDefVis


function sigma(x,k)
    return 1 / (1 + exp(-k * x))
end

function connectProbability(graph,types,fitnesses, a,b,c,k,e)
	if (types[a] == 0) && (types[c] == 1) && (rand() < e)
		return 1.0
	else
		return sigma(fitnesses[b] - fitnesses[a],k)
	end
end


function judgeEgoDefVis(graph, types, fitnesses, a,b,c, k,e)
	pa = connectProbability(graph,types,fitnesses,a,b,c,k,e)
	pb = connectProbability(graph,types,fitnesses,c,b,a,k,e)	
	return pa * pb
end

function makeJudgeEgoDefVis(e)
	f(G,t,f,a,b,c,k) = judgeEgoDefVis(G,t,f,a,b,c,k,e)
	return f
end

end