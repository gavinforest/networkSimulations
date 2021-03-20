using Plots
using CSV
using DataFrames
using ArgParse
# using Statistics

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "-N"
            help = "an option with an argument"
            arg_type = Int
      		required = true
        # "--opt2", "-o"
        #     help = "another option with an argument"
        #     arg_type = Int
        #     default = 0
        # "--flag1"
        #     help = "an option without argument, i.e. a flag"
        #     action = :store_true
        # "arg1"
        #     help = "a positional argument"
        #     required = true
    end

    return parse_args(s)
end

function makeWinsPlot(popsize)

	root = "/Users/gavin/Documents/Stay_Loose/Research/Evolutionary_Dynamics/networkSimulations"

	frame = CSV.read("$root/data/nonRivalCoopWins$popsize.csv")

	averaged = by(frame, :coop, [:payoffDiff, :fitDiff] =>  x -> (pwins = sum([1.0 for i in x.payoffDiff if i > 0.0])/length(x.payoffDiff), 
																fwins = sum([1.0 for i in x.fitDiff if i > 0.0])/length(x.fitDiff)))
	winsMat = convert(Matrix, averaged[:, [:pwins,:fwins]])
	coops = unique(frame, :coop).coop
	# @show coops
	# @show winsMat
	s = "Cooperator Preference by Proportion, N = $popsize"

	myplot = scatter(coops, winsMat, label= ["By payoff" "By fitness"], title = s);
	ylabel!(myplot, "Proportion of Cooperator Victories");
	xlabel!(myplot, "Proportion Cooperators in Population");
	savefig(myplot, "$root/figs/nonRivalCoopWins$popsize.png");
end 

function main()
	parsed_args = parse_commandline()
	N = parsed_args["N"]
	# println("Called with N = $N")
	makeWinsPlot(N)
end
main()


