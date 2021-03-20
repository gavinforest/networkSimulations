# using Distributed

# @everywhere begin
#     println(include("testInclude.jl"))
#     # using .included
#     println("included says $(included.exported())")
# end

# println(include("testInclude.jl"))
# using .included
# println("included says $(exported())")
# push!(LOAD_PATH,pwd())
# import models
# models.greet()
using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--opt1"
            help = "an option with an argument"
        "--opt2", "-o"
            help = "another option with an argument"
            arg_type = Int
            default = 0
        "--flag1"
            help = "an option without argument, i.e. a flag"
            action = :store_true
        "arg1"
            help = "a positional argument"
            required = true
    end

    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    println("Parsed args:")
    for (arg,val) in parsed_args
        @show (arg,val)
    end
end

main()