.PHONY: all
all : NREdata figures examples
NREdata: NREdata10 NREdata100 NREdata300 NREdataDefVis NREdegreeDist
NREdataDefVis : defVis10 defVis100 defVis300

NREdata%: data/nonRivalCoopWins%.csv data/baseNonRivalCoopWins%.csv data/nonRivalCoopWins%TS.csv
defVis%: data/nonRivalDefVisCoopWins%.csv data/nonRivalDefVisCoopWins%TS.csv 
defAcceptDefCost%: data/defAcceptDefCostCoopWins%.csv 
degreeDist: data/nonRivalDegreeDist20000.csv

data/nonRivalCoopWins%.csv data/nonRivalCoopWins%TS.csv : experiments/nonRivalCoopWins%.jl
	@echo "Generating data/nonRivalCoopWins$*.csv, TS.csv data";
	cd $(<D); julia $(<F)

data/baseNonRivalCoopWins%.csv : experiments/baseNonRivalCoopWins%.jl
	@echo "Generating data/baseNonRivalCoopWins$*.csv data";
	cd $(<D); julia $(<F)

data/nonRivalDefVisCoopWins%.csv data/nonRivalDefVisCoopWins%TS.csv: experiments/nonRivalDefVisCoopWins.jl
	@echo "Generating data/nonRivalDefVisCoopWins$*.csv data"
	cd $(<D); julia $(<F) -N $*

data/defAcceptDefCostCoopWins%.csv : experiments/defAcceptDefCostCoopWins.jl
	@echo "Generating data/nonRivalDefCostCoopWins$*.csv data"
	cd $(<D); julia $(<F) -N $*


data/nonRivalDegreeDist%.csv: experiments/nonRivalDegreeDistribution.jl
	@echo "Generating data/nonRivalDegreeDist$*.csv data"
	cd $(<D); julia $(<F) -N $*

figures: nonRivalWins baseNonRivalWins nonRivalTimeSeries defVisWinPlots
nonRivalWins: figs/nonRivalCoopWins100.png figs/nonRivalCoopWins10.png figs/nonRivalCoopWins300.png
baseNonRivalWins : figs/baseNonRivalCoopWins100.png figs/baseNonRivalCoopWins10.png figs/baseNonRivalCoopWins300.png
nonRivalTimeSeries: figs/nonRivalTSeries10.png figs/nonRivalTSeries100.png figs/nonRivalTSeries300.png
defVisWinPlots: figs/nonRivalDefVisCoopWins100.png figs/nonRivalDefVisCoopWins300.png
defAcceptDefCostPlots : figs/defAcceptDefCostCoopWins100.png
# baselineNonRivalTimeSeries: figs/baselineNonRivalTSeries10.png figs/baselineNonRivalTSeries100.png figs/baselineNonRivalTSeries300.png


figs/nonRivalCoopWins%.png : plotters/nonRivalWinsPlots.jl data/nonRivalCoopWins%.csv 
	@echo "Generating win plot from nonRivalCoopWins$*.csv data";
	cd $(<D); julia $(<F) -N $*

figs/defAcceptDefCostCoopWins%.png : plotters/defAcceptDefCostWinsPlots.jl data/defAcceptDefCostCoopWins%.csv 
	@echo "Generating win plot from nonRivalCoopWins$*.csv data";
	cd $(<D); julia $(<F) -N $*

figs/baseNonRivalCoopWins%.png : plotters/baseNonRivalWinsPlots.jl data/baseNonRivalCoopWins%.csv 
	@echo "Generating win plot from baseNonRivalCoopWins$*.csv data";
	cd $(<D); julia $(<F) -N $*

figs/nonRivalTSeries%.png: plotters/nonRivalTSPlotter.jl data/nonRivalCoopWins%TS.csv
	@echo "Generating time series plot from nonRivalCoopWins$*.csv data";
	cd $(<D); julia $(<F) -N $* -f 0.5

figs/nonRivalDefVisCoopWins%.png: plotters/nonRivalDefVisWinPlotter.jl data/nonRivalDefVisCoopWins%.csv
	@echo "Generating wins plot from nonRivalDefVisCoopWins$*.csv data";
	cd $(<D); julia $(<F) -N $*

examples: experiments/makeExampleGraphs.jl plotters/generateExamples.sh 
	@echo "making example graphs"
	cd $(<D); julia $(<F) -N 10 -C 5 -i 10


