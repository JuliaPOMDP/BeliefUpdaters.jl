using Documenter, BeliefUpdaters

makedocs()

deploydocs(
           deps = Deps.pip("mkdocs"),
           repo = "github.com/JuliaPOMDP/BeliefUpdaters.jl",
           julia = "1.0"
          )