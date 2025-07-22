using NAVCal
using Documenter

DocMeta.setdocmeta!(NAVCal, :DocTestSetup, :(using NAVCal); recursive=true)

makedocs(;
    modules=[NAVCal],
    authors="Graham Harper Edwards",
    sitename="NAVCal.jl",
    format=Documenter.HTML(;
        canonical="https://grahamedwards.github.io/NAVCal.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/grahamedwards/NAVCal.jl",
    devbranch="main",
)
