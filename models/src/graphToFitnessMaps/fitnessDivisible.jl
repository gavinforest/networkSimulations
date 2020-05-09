module fitnessDivisible

using LightGraphs

export GtoFDivisibleTemplate, getIndFitDivisible

function generateFitnessFromGraphDivisible(G, types, b, c, w)
    payoffs = [0.0 for i in 1:nv(G)]
    for v in vertices(G)
        for j in inneighbors(G,v)
            if (types[j] == 1)
                payoffs[v] += b / (outdegree(G,j) * 1.0)
            end
        end
        # if degree(G,v) > 0
        #     payoffs[v] -= c * types[v]
        # end
    end
    
    fitnesses = [exp(w * p) for p in payoffs]
    return fitnesses  
end

function getIndFitDivisible(v, G, types, b, c, w)
    myPayoff = 0.0
    for j in inneighbors(G,j)
        if (types[j] == 1)
            myPayoff += b / (outdegree(G,j) * 1.0)
        end
    end
    myPayoff -= c
    return exp(w * myPayoff)
end

function GtoFDivisibleTemplate(b,c,w)
    f(g,types) = generateFitnessFromGraphDivisible(g,types,b,c,w)
    return f
end

end