using Distributed
using DataFrames
using ArgParse
import CSV

PROCS = 5
toAdd = PROCS - nprocs()
addedProcs = addprocs(toAdd)

@everywhere begin
    root = "/Users/gavin/Documents/Stay_Loose/Research/Evolutionary_Dynamics/networkSimulations"
	push!(LOAD_PATH, root)
	# println("LOAD_PATH is $LOAD_PATH")
end


function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "-N"
            help = "an option with an argument"
            arg_type = Int
      		required = true
    end

    return parse_args(s)
end


parsed_args = parse_commandline()
@eval @everywhere N = $(parsed_args["N"])

@everywhere begin
	import models
	using LightGraphs

	using models.simulateIntroductionModel
	using models.judgerSigmaEgo
	using models.fitnessNonRival
	using models.mutateUniform
	using models.degreeDistributionAveraged


	numRounds = 2000000
	function mySimulator(;coopProp = 0.5, intensity = 0.01)
		G = random_regular_graph(N,round(Int,sqrt(N)/2))
		nCoops = floor(Int, coopProp * nv(G))
		
		types = [0 for i in 1:nv(G)]
		for j in 1:nCoops
			types[j] = 1
		end

		fitFunc = GtoFNonRivalTemplate(5,1,intensity)
		updater = fitUpdaterTemplate(5,1,intensity)
		judge = judgeSigmaEgo
		mut = makeMutator(1.0)
		return simulateIntroModel(G,types,numRounds,judge, fitFunc, mut, fitUpdater! = updater, averagePeriod = 0.0)
	end
end
nTrials = 10
println("Starting the degree dist farmer")
@time resultDf = degDistAvg(mySimulator, numTrials = nTrials, N = N)


CSV.write("$root/data/nonRivalDegDist$(N).csv", resultDf)



# outgraph, outAvgFits, outTypes, outSamples = simulateIntroModel(G,types,1000000,judge, fitFunc, mut, sampleInterval = 50000)
# println(resultArray)
rmprocs(addedProcs)
println("Done")
