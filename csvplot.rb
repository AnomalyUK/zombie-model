require 'zombies'

module Zombie
  class CsvPlotter
    def initialize(fname)
      @filename=fname
    end

    def plot(pop)
      File.open( @filename, "w" ) do |out|
        time = pop.time
        s = pop.s

        cols=s.keys
        out.print "t"
        cols.each { |var| out.print ",#{var}" }
        out.print "\n"

        time.each_with_index do |t,i|
          out.print t
          cols.each do |var|
            out.print ",#{s[var][i]}"
          end
          out.print "\n"
        end
      end
    end
  end
end
