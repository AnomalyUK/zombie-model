require 'rotting'

shock = 1.0
shock = ARGV[0].to_f if ARGV[0]

# The populations start in equilibrium.  At t=1000, the human population
# is decreased from 480 to 479, and the number of corpses from 200 to
# 201.  By the time a new equilibrium is reached, population has dropped
# to 466.  The effect of the background zombie level, therefore, is to 
# amplify events causing deaths by a factor of 34.
#
# A big enough shock will wipe out the population.  Killing 35 of the 
# population of 480, the rate of population drop caused by the continued
# supply of newly-risen zombies is so fast that the zombie level does not
# stabilise, and humans are exterminated

exp1 = Population.new(1000,0.02,480)
exp1.now['corpses'] = 200.0
exp1.now['zombies'] = 5.0/24

func2 = Rotting.new( 'alpha' => 0.01, 
                     'beta' => 0.0096, 
                     'zeta' => 0.0002, 
                     'delta' => 0.00105,
                     'lambda' => 0.00232,
                     'zombies_in' => [[1000,'humans',0,-shock],
                                      [1000,'corpses',0,shock]],
                     'pi' => 0.002 )


func2.run( exp1, 1000000 )
print "plotting\n"
exp1.plot
puts exp1

