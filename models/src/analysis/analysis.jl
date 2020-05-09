module analysis

using LightGraphs, StatsBase

export meanFitnessesCD, averageDegreesCD, strategyPreferences,
          getFdiffU, getFcoopFdefU, getPdiffU, getPcoopPdefU

function meanFitnessesCD(agentScores, types)\
    coopmean = mean([agentScores[j] for j in 1:length(agentScores) if types[j]==1])
    defmean = mean([agentScores[j] for j in 1:length(agentScores) if types[j]==0])
    return coopmean, defmean
end

function averageDegreesCD(graph, types)
    coopAvgDegree = mean([degree(graph,v) for v in 1:nv(graph) if types[v]==1])
    defectAvgDegree = mean([degree(graph,v) for v in 1:nv(graph) if types[v]==0])
    return coopAvgDegree, defectAvgDegree
end

function strategyPreferences(G, agentScores, types)
    N = length(agentScores)
    cooperatorNum = sum(types)
    defectorNum = N - cooperatorNum
    cooperatorConnections = 0
    defectorConnections = 0
    for i in 1:N
        outCooperators = sum([types[j] for j in outneighbors(G,i)])
        if types[i] == 1
            cooperatorConnections += outCooperators
        else
            defectorConnections += outCooperators
        end
    end
    cooperatorOutCoopProp = cooperatorConnections / cooperatorNum
    defectorOutCoopProp = defectorConnections / defectorNum
    
#     println("Cooperators connect to on average $cooperatorOutCoopProp cooperators")
#     println("Defectors connect to on average $defectorOutCoopProp cooperators")
    return cooperatorOutCoopProp, defectorOutCoopProp
                           
end

function getFdiffU(G, agentScores, types, coopP)
	coopConnects, defConnects = strategyPreferences(G, agentScores, types)
    coopAvgDegree, defAvgDegree = averageDegreesCD(G, types)
    coopPreference = coopConnects / coopAvgDegree
    defPreference = 1 - (defConnects / defAvgDegree) # going for same type preference
    u = coopPreference * coopP + defPreference * (1-coopP)

    coopFit, defFit = meanFitnessesCD(agentScores, types)
    f = coopFit - defFit

    return (f,u)
end


function getFcoopFdefU(G, agentScores, types, coopP)
	coopConnects, defConnects = strategyPreferences(G, agentScores, types)
    coopAvgDegree, defAvgDegree = averageDegreesCD(G, types)
    coopPreference = coopConnects / coopAvgDegree
    defPreference = 1 - (defConnects / defAvgDegree) # going for same type preference
    u = coopPreference * coopP + defPreference * (1-coopP)

    coopFit, defFit = meanFitnessesCD(agentScores, types)
    
    return (coopFit, defFit, u)
end

function scoresToPayoffs(agentScores,w)
    payoffs = [0.0 for i in 1:length(agentScores)]
    for i in 1:length(agentScores)
        payoffs[i] = log(agentScores[i]) / w
    end
    return payoffs
end

function getPdiffU(G,agentScores,types,w,coopP)
    payoffs = scoresToPayoffs(agentScores,w)
    return getFdiffU(G, payoffs,types,coopP)
end

function getPcoopPdefU(G, agentScores, types, w, coopP)
    payoffs = scoresToPayoffs(agentScores, w)
    return getFcoopFdefU(G, payoffs, types, coopP)
end






end