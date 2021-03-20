module fitnessAveraged

using LightGraphs

export GtoFAveragedTemplate, getIndFitAveraged
# , fitUpdaterTemplateAveraged

function generateFitnessFromGraphAveraged(G, types, b, c, w)
    payoffs = [0.0 for i in 1:nv(G)]
    for v in vertices(G)
        if types[v] == 1
            for j in outneighbors(G,v)
                payoffs[j] += b
            end
        end
    end

    payoffs = [payoffs[i] / indegree(G,i) for i in vertices(G)]
    for v in vertices(G)
        if types[v] == 1
            payoffs[v] -= c
        end
    end

    fitnesses = [exp(w * p) for p in payoffs]
    return fitnesses
end

function getIndFitAveraged(v, G, types, b, c, w)
    myPayoff = 0.0
    for j in inneighbors(G,v)
        if (types[j] == 1)
            myPayoff += b
        end
    end
    myPayoff = myPayoff / indegree(G,v)
    if types[v] == 1
        myPayoff -= c
    end
    return exp(w * myPayoff)
end

function GtoFAveragedTemplate(b,c,w)
	f(g,types) = generateFitnessFromGraphAveraged(g,types,b,c,w)
	return f
end

# function fitnessUpdater(G, fitnesses, types, addEdge, remEdge, b,c,w)
#     fitnesses[addEdge[1]] = fitnesses[addEdge[1]] * exp(w * b * types[addEdge[2]])
#     fitnesses[addEdge[2]] = fitnesses[addEdge[2]] * exp(w * b * types[addEdge[1]])
    
#     fitnesses[remEdge[1]] = fitnesses[remEdge[1]] / exp(w * b * types[remEdge[2]])
#     fitnesses[remEdge[2]] = fitnesses[remEdge[2]] / exp(w * b * types[remEdge[1]])
# end

# function fitUpdaterTemplateAveraged(b,c,w)
#     f(G,fits, types, added, remed) = fitnessUpdater(G, fits, types, added, remed, b,c,w)
#     return f
# end

end