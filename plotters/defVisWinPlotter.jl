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
      	"--fitness"
      		help = "The fitness function"
      		arg_type = String
      		default = "nonRival"
      	"-k"
      		help = "Shape parameter for judger"
      		arg_type = Float64
      		default = 1.0
    end

    return parse_args(s)
end


parsed_args = parse_commandline()
N = parsed_args["N"]
fName = parsed_args["fitness"]
k = parsed_args["k"]

function makeWinsPlot()

	root = "/Users/gavin/Documents/Stay_Loose/Research/Evolutionary_Dynamics/networkSimulations"
	if k == 1.0
		frame = CSV.read("$root/data/$(fName)DefVisCoopWins$N.csv")
	else
		frame = CSV.read("$root/data/$(fName)DefVisk$(round(Int,k))CoopWins$N.csv")
	end


	averaged = by(frame, :epsilon, [:payoffDiff, :fitDiff] =>  x -> (pwins = sum([1.0 for i in x.payoffDiff if i > 0.0])/length(x.payoffDiff), 
																fwins = sum([1.0 for i in x.fitDiff if i > 0.0])/length(x.fitDiff)))
	winsMat = convert(Matrix, averaged[:, [:pwins,:fwins]])
	epsilons = unique(frame, :epsilon).epsilon
	# @show coops
	# @show winsMat
	s = "Cooperator Preference by Defector Visibility, N = $N"

	myplot = scatter(epsilons, winsMat, label= ["By payoff" "By fitness"], title = s, dpi = 250);
	ylabel!(myplot, "Proportion of Cooperator Victories");
	xlabel!(myplot, "Cooperator Visibility");
	if k == 1.0
		savefig(myplot, "$root/figs/$(fName)DefVisCoopWins$N.png");
	else
		savefig(myplot, "$root/figs/$(fName)DefVisk$(round(Int,k))CoopWins$N.png");
	end

end 

makeWinsPlot()


