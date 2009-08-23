require 'rotting'

# negative or positive population shock?
shock = -0.05
shock = 0.05 if ARGV[0] == "plus"

# The populations start in equilibrium.  At t=1000, 5% of humans
# vanish - they don't become corpses, they just disappear.  That is
# a drop in population from 480 to 456.  The result of that is that
# there are now 5% too many corpses for the population - that results
# in a sustained increase in the number of zombies, and by the time 
# the zombie numbers are suppressed, the population has dropped even 
# more, to below 365.
#
# with a command line argument "plus", the number of humans is increased
# rather than decreased by 5%.  Again, the new population of 504 grows
# to over 595 before the zombie level recovers to 5/24

exp1 = Population.new(1000,0.02,480)
exp1.now['corpses'] = 200.0
exp1.now['zombies'] = 5.0/24

func2 = Rotting.new( 'alpha' => 0.01, 
                     'beta' => 0.0096, 
                     'zeta' => 0.0002, 
                     'delta' => 0.00105,
                     'lambda' => 0.00232,
                     'zombies_in' => [[1000,'humans',shock,0]],
                     'pi' => 0.002 )


func2.run( exp1, 500000 )
print "plotting\n"
#exp1.clip(850,855,0.05)
exp1.plot
puts exp1

