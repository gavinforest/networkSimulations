module fitnessClassical

using LightGraphs

export GtoFClassicalTemplate, getIndFitClassical, fitUpdaterTemplateClassical

function generateFitnessFromGraphClassical(G, types, b, c, w)
    payoffs = [0 for i in 1:nv(G)]
    for v in vertices(G)
        for j in inneighbors(G,v)
            payoffs[v] += b * types[j]
        end
        payoffs[v] -= c * length(outneighbors(G,v)) * types[v]
    end
    
    fitnesses = [exp(w * p) for p in payoffs]
    return fitnesses  
end

function getIndFitClassical(v, G, types, b, c, w)
    myPayoff = 0.0
    for j in inneighbors(G,j)
        myPayoff += b * types[j]
    end
    myPayoff -= c * outDegree(G,v) * types[v]
    return exp(w * myPayoff)
end

function GtoFClassicalTemplate(b,c,w)
	f(g,types) = generateFitnessFromGraphClassical(g,types,b,c,w)
    return f
end

function fitnessUpdater(G, fitnesses, types, addEdge, remEdge, b,c,w)
    #adding edge benefits
    fitnesses[addEdge[1]] = fitnesses[addEdge[1]] * exp(w * b * types[addEdge[2]])
    fitnesses[addEdge[2]] = fitnesses[addEdge[2]] * exp(w * b * types[addEdge[1]])
    #paying costs associated with additional edge
    fitnesses[addEdge[1]] = fitnesses[addEdge[1]] / exp(w * c * types[addEdge[1]])
    fitnesses[addEdge[2]] = fitnesses[addEdge[2]]/ exp(w * c * types[addEdge[2]])

    #removing edge benefits
    fitnesses[remEdge[1]] = fitnesses[remEdge[1]] / exp(w * b * types[remEdge[2]])
    fitnesses[remEdge[2]] = fitnesses[remEdge[2]] / exp(w * b * types[remEdge[1]])
    #giving back cost from now removed edge
    fitnesses[remEdge[1]] = fitnesses[remEdge[1]] * exp(w * c * types[remEdge[1]])
    fitnesses[remEdge[2]] = fitnesses[remEdge[2]] * exp(w * c * types[remEdge[2]])

end

function fitUpdaterTemplateClassical(b,c,w)
    f(G,fits, types, added, remed) = fitnessUpdater(G, fits, types, added, remed, b,c,w)
    return f
end

end