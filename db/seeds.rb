# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

LANGUAGES_LIST = %w(Ada Bash C/C++/C# Clojure CUDA Elixir Erlang Fortran Go Haskell
                    Java Javascript Julia LaTeX Lisp OpenCL Pascal Perl PHP Python
                    Mathematica Matlab R Ruby Rust Scala SQL Swift)
LANGUAGES_LIST.each do |lang|
  Language.find_or_create_by(name: lang)
end
