require 'rotting'

# The populations start in equilibrium.  Three disturbances
# occur - the number of zombies is doubled at t=200.  Then
# all zombies are eliminated at t=1000.  In both cases a new
# equilibrium is quickly reached with a small change in the
# human population.  Then at t=2000, all corpses are eliminated.
# The result is a huge surge in human population, which has
# nearly quadrupled and is still increasing at t=5000

exp1 = Population.new(1000,0.02,480)
exp1.now['corpses'] = 200.0
exp1.now['zombies'] = 5.0/24

func2 = Rotting.new( 'alpha' => 0.01, 
                  'beta' => 0.0096, 
                  'zeta' => 0.0002, 
                  'delta' => 0.00105,
                  'lambda' => 0.00232,
                  'zombies_in' => [[200,'zombies',1.0,0],
                                   [1000,'zombies',-1.0,0],
                                   [2000,'corpses',-1.0,0]],
                  'pi' => 0.002 )



func2.run( exp1, 500000 )
print "plotting\n"
#exp1.clip(850,855,0.05)
#exp1.plot
puts exp1

