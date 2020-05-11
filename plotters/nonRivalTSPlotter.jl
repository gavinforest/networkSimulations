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
        "-i"
            help = "Get a single tseries out"
            arg_type = Int
            default = -1
    end

    return parse_args(s)
end

function makeTSeriesPlot(popsize, frac, ID)

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

    if ID == -1
        tseries = frame |> @filter((_.id >= IDstart) && (_.id <= IDend) ) |> DataFrame
    else
        tseries = frame |> @filter((_.id == IDstart + ID)) |> DataFrame
    end

    uns = unique(tseries, :n)
    gens = uns.n
    # @show (gens[1:6])
    # @show (tseries |> @take(6) |> DataFrame)

    averagedSeries = tseries |> 
                @groupby(_.n) |> 
                @map({fcoop = mean(_.fcoop), fdef = mean(_.fdef),
                        u = mean(_.u), n = key(_), 
                        wins = sum([1.0 for (i, j) in zip(_.fcoop, _.fdef) if i > j])/length(_.fcoop)}) |>
                @orderby(_.n) |>
                DataFrame

    # averagedSeries = averagedSeries |> @take(6) |> DataFrame
    # gens = gens[1:6]

	statMat = convert(Matrix, averagedSeries[:, [:fcoop, :fdef, :u, :wins]])
	# winsMat = convert(Matrix, averaged[:, [:pwins,:fwins]])
	# coops = unique(frame, :coop).coop
	# @show coops
	# @show winsMat
    # @show size(statMat)
    # @show size(gens)
	s = "Time Series of Process, N = $popsize, F = $frac"
    labels = ["Avg. Cooperator Fitness" "Avg. Defector Fitness" "Segregation Coefficient u" "Proportion of Cooperator Wins"]

	myplot = scatter(gens, statMat, label= labels, title = s);
	ylabel!(myplot, "Cross Sample Averages");
	xlabel!(myplot, "Time Steps");
	savefig(myplot, "$root/figs/nonRivalTSeries$popsize.png");
end 

function main()
	parsed_args = parse_commandline()
	N = parsed_args["N"]
    f = parsed_args["f"]
    ID = parsed_args["i"]
	# println("Called with N = $N")
	makeTSeriesPlot(N,f, ID)
end
main()


