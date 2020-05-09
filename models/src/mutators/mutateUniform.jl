module mutateUniform

using LightGraphs, StatsBase

export makeMutator

function randEdge(G)
    return collect(edges(G))[ceil(Int, rand()*ne(G))]
end



function mutator(G, elist,mutationRate)
# function mutator(G, mutationRate)

	if rand() < mutationRate
		N = nv(G)
        toCreate  = sample(1:N, AnalyticWeights([1 for j in 1:N]),2, replace=false)
        # toDestroy = randEdge(G)
        i = ceil(Int, rand()*length(elist))
        toDestroy = elist[i]
        # @assert toCreate[1] != toCreate[2]
        if !has_edge(G, toCreate[1], toCreate[2])
            add_edge!(G,toCreate[1],toCreate[2])
            rem_edge!(G, toDestroy[1], toDestroy[2])
            # rem_edge!(G,toDestroy)
            # return (toCreate[1],toCreate[2]),(src(toDestroy),dst(toDestroy))
            return (toCreate[1],toCreate[2]),(toDestroy[1],toDestroy[2]), i
        end
    end
    return (-1,-1), (-1,-1), -1
end

function makeMutator(mutRate)
	f(g, elist) = mutator(g,elist,mutRate)
    # f(g) = mutator(g, mutRate)
	return f
end

end
