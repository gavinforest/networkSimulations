module simulateIntroductionModel

root = "/Users/gavin/Documents/Stay_Loose/Research/Evolutionary_Dynamics/networkSimulations"
include("$root/models/src/analysis/analysis.jl")

using LightGraphs, StatsBase

using .analysis

export simulateIntroModel

function testEdgeListEquality(graph, edges)
    for (t,f) in edges
        if !has_edge(graph, t,f)
            return false
        end
    end
    if ne(graph) != length(edges)
        return false
    end
    return true
end


function simulateIntroModel(graph, types,numRounds, introJudger, graphToFit, mutation; averagePeriod = 0.1, sampleInterval = -1, k = 1.0, fitUpdater! = Nothing, w = 0.01)
	# println("Starting simulateIntroModel")
    coopP = (1.0 * sum(types)) / length(types)
    fitnesses = graphToFit(graph, types)
    N = nv(graph)
    NE = ne(graph)
    graphEdges = collect(edges(graph))
    myEdges::Array{Tuple{Int, Int},1} = [(src(e),dst(e)) for e in graphEdges]
	averageFitnesses::Array{Float64,1} = [0.0 for i in 1:N]
    samples::Array{Tuple{Int,Float64, Float64,Float64,Float64,Float64},1} = []
    # println("About to start loop")
	for n in 1:numRounds
        # if numRounds % 10000 == 1
            # println("hi")
        # end
        b = ceil(Int, rand()*N)
        candidates = neighbors(graph,b)
        nCandidates = length(candidates)
        if (nCandidates > 1)
            toIntro  = sample(candidates, AnalyticWeights(fill(1.0, nCandidates)),2, replace=false)
            a = toIntro[1]
            c = toIntro[2]
            # @assert a != c
            if (!has_edge(graph,a,c))
            	pConnect = introJudger(graph, types, fitnesses, a,b,c,k)
                if (rand() < pConnect)
                    ind = ceil(Int, rand()*NE)
                    toRemove = myEdges[ind]
                    # toRemove = collect(edges(graph))[rand(1:ne(graph))]
                    # rem_edge!(graph, toRemove)
                    rem_edge!(graph,toRemove[1],toRemove[2])
                    add_edge!(graph, a, c)
                    myEdges[ind] = (a,c)
                    # @assert testEdgeListEquality(graph, myEdges)

                    if fitUpdater! == Nothing
                        fitnesses = graphToFit(graph, types)
                    else
                        # fitUpdater!(graph, fitnesses, types, (a,c), (src(toRemove),dst(toRemove)))
                        fitUpdater!(graph, fitnesses, types, (a,c), toRemove)

                    end
                end
            end
        end

        # added,remed = mutation(graph)
        added, remed, ind= mutation(graph, myEdges)
        if ind > 0
            myEdges[ind] = added
        end
        # @assert testEdgeListEquality(graph, myEdges)

        if added[1] != -1
            if fitUpdater! == Nothing
                fitnesses = graphToFit(graph,types)
            else
                fitUpdater!(graph, fitnesses, types, added, remed)
            end
        end

        if (n > numRounds * (1-averagePeriod))
            averageFitnesses += fitnesses / (numRounds * averagePeriod)
        end

        if (sampleInterval > 0) && (n % sampleInterval == 1)
            fcoop,fdef,u = getFcoopFdefU(graph, fitnesses, types, coopP)
            pcoop, pdef, u = getPcoopPdefU(graph, fitnesses, types, w, coopP)
            push!(samples, (n,fcoop,fdef,pcoop,pdef,u))
        end

    #     println("$n complete")
    end

    @assert testEdgeListEquality(graph, myEdges)

    if length(samples) == 0
        fcoop,fdef,u = getFcoopFdefU(graph, fitnesses, types, coopP)
        pcoop, pdef, u = getPcoopPdefU(graph, fitnesses, types, w, coopP)
        push!(samples, (numRounds,fcoop,fdef,pcoop,pdef,u))
    end

    if (numRounds == 0) || (averagePeriod == 0.0) 
        averageFitnesses = fitnesses
    end

#     myplot = plot(agentScores, [length(neighbors(G1,i)) for i in 1:N], seriestype=:scatter)
#     theplot = generalStatPlot(G1, agentScores)

    return graph, averageFitnesses, types, samples
end

end
