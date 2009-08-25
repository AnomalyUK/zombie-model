require 'zombie'
require 'gnuplot'

module Zombie
  class GnuPlotter
    def plot(pop)
      time = pop.time
      s = pop.s

      Gnuplot.open do |gp|
        Gnuplot::Plot.new( gp ) do |plot|

          zombiescale=1000
          
          plot.xrange "[#{time.first}:#{time.last}]"
          plot.title  "Zombie Attack"
          plot.ylabel "Population"
          plot.xlabel "time"
          
          plot.data << Gnuplot::DataSet.new( [time,scale(s['zombies'],zombiescale) ] ) do |ds|
            ds.title = "Zombies x #{zombiescale}"
            ds.with = "lines lc rgb \"red\""
            ds.linewidth = 2
          end

          plot.data << Gnuplot::DataSet.new( [time,s['humans'] ] ) do |ds|
            ds.title = "Humans"
            ds.with = "lines lc rgb \"blue\""
            ds.linewidth = 2
            ds
          end
        end
      end
    end
  end
end
