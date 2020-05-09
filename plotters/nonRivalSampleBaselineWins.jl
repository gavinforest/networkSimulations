using Plots
using CSV
using DataFrames
using ArgParse
using Query
using Statistics

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "-N"
            help = "Population size"
            arg_type = Int
      		required = true
        "-f"
            help = "Cooperator fraction"
            arg_type = Float64
            required = true
    end

    return parse_args(s)
end

function makeTSeriesPlot(popsize, frac)

	root = "/Users/gavin/Documents/Stay_Loose/Research/Evolutionary_Dynamics/networkSimulations"

	frame = CSV.read("$root/data/nonRivalCoopWins$(popsize)TS.csv")
    resultsFrame = CSV.read("$root/data/nonRivalCoopWins$(popsize).csv")

    coops = resultsFrame.coop
    IDstart = length(coops)
    IDend = 0
    for i in 1:length(coops)
        if (abs(coops[i] - frac) < 0.00001)
            if i < IDstart
                IDstart = i
            elseif i > IDend
                IDend = i
            end
        end
    end

    if IDend == 0
        println("Cooperator fraction not found in data. Exiting")
        exit()
    end


    tseries = frame |> @filter((_.id >= IDstart) && (_.id <= IDend) ) |> DataFrame
    uns = unique(tseries, :n)
    gens = uns.n
    # @show (gens[1:6])
    # @show (tseries |> @take(6) |> DataFrame)

    initialWins = tseries |> 
                @groupby(_.id) |> 
                @map({id = key(_), wins = (_.fcoop[1] > _.fdef[1]) ? 1.0 : 0.0}) |>
                @orderby(_.id) |>
                DataFrame
    initialWins.coop = resultsFrame.coop

    winsPer = initialWins |>
                @groupby(_.coop) |>
                @map({coop = key(_), winprop = mean(_.wins)}) |>
                @orderby(_.coop) |>
                DataFrame

	# statMat = convert(Matrix, averagedSeries[:, [:fcoop, :fdef, :u, :wins]])
	# winsMat = convert(Matrix, averaged[:, [:pwins,:fwins]])
	# coops = unique(resultsFrame, :coop).coop
	# @show coops
	# @show winsMat
    # @show size(statMat)
    # @show size(gens)
	s = "Baseline Cooperator Wins from Samples, N=$popsize"
    labels = ["Proportion of Cooperator Wins"]

	myplot = scatter(winsPer.coop, winsPer.winprop, label= labels, title = s);
	ylabel!(myplot, "Proportion of Cooperator Wins at t = 0");
	xlabel!(myplot, "Cooperator Proportion in Population");
	savefig(myplot, "$root/figs/baselineNonRivalTSeries$popsize.png");
end 

function main()
	parsed_args = parse_commandline()
	N = parsed_args["N"]
    f = parsed_args["f"]
	# println("Called with N = $N")
	makeTSeriesPlot(N,f)
end
main()


