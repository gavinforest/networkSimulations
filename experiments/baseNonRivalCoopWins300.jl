using Distributed
using DataFrames
import CSV

PROCS = 5
toAdd = PROCS - nprocs()
addedProcs = addprocs(toAdd)

@everywhere begin
    root = "/Users/gavin/Documents/Stay_Loose/Research/Evolutionary_Dynamics/networkSimulations"
	push!(LOAD_PATH, root)
	# println("LOAD_PATH is $LOAD_PATH")
end

@everywhere begin
	import models
	using LightGraphs

	using models.simulateIntroductionModel
	using models.judgerSigmaEgo
	using models.fitnessNonRival
	using models.mutateUniform
	using models.segregationDistributionAveraged



	function mySimulator(;coopProp = 0.5, intensity = 0.01)
		G = random_regular_graph(300,5)
		nCoops = floor(Int, coopProp * nv(G))
		types = [0 for i in 1:nv(G)]
		for j in 1:nCoops
			types[j] = 1
		end

		fitFunc = GtoFNonRivalTemplate(5,1,intensity)
		updater = fitUpdaterTemplate(5,1,intensity)
		judge = judgeSigmaEgo
		mut = makeMutator(0.01)
		return simulateIntroModel(G,types,0,judge, fitFunc, mut, sampleInterval = 50000, fitUpdater! = updater)
	end
end
coopPropRange = [0.01 * i for i in 1:99]
nTrials = 10000
@time resultDf, seriesDf = segDistAvg(mySimulator, numTrials = nTrials, coopPropRange = coopPropRange)


CSV.write("$root/data/baseNonRivalCoopWins300.csv", resultDf)



# outgraph, outAvgFits, outTypes, outSamples = simulateIntroModel(G,types,1000000,judge, fitFunc, mut, sampleInterval = 50000)
# println(resultArray)
rmprocs(addedProcs)
println("Done")
