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


	sampleInt = 5000
	numRounds = 100000
	numSamples = ceil(Int, numRounds/sampleInt)
	function mySimulator(;coopProp = 0.5, intensity = 0.01)
		G = random_regular_graph(10,5)
		nCoops = floor(Int, coopProp * nv(G))
		types = [0 for i in 1:nv(G)]
		for j in 1:nCoops
			types[j] = 1
		end

		fitFunc = GtoFNonRivalTemplate(5,1,intensity)
		updater = fitUpdaterTemplate(5,1,intensity)
		judge = judgeSigmaEgo
		mut = makeMutator(0.01)
		return simulateIntroModel(G,types,numRounds,judge, fitFunc, mut, sampleInterval = sampleInt, fitUpdater! = updater)
	end
end
coopPropRange = [0.1 * i for i in 1:9]
nTrials = 100
@time resultDf, seriesDf = segDistAvg(mySimulator, numTrials = nTrials, coopPropRange = coopPropRange, numSamples= numSamples)


CSV.write("$root/data/nonRivalCoopWins10.csv", resultDf)
CSV.write("$root/data/nonRivalCoopWins10TS.csv", seriesDf)



# outgraph, outAvgFits, outTypes, outSamples = simulateIntroModel(G,types,1000000,judge, fitFunc, mut, sampleInterval = 50000)
# println(resultArray)
rmprocs(addedProcs)
println("Done")
