require 'zombies'

# evolves a Population as proposed by Munz et al 2009
class Orig < Model

 def change( old )
   c = Hash.new
   dt = old.dt

   c['humans']  = -dt*p['beta']*old['humans']*old['zombies']
   c['zombies'] = dt*(p['beta']*old['humans']*old['zombies'] -
                      p['alpha']*old['humans']*old['zombies'] +
                      p['zeta']*old['corpses'])
   c['corpses'] = dt*(p['alpha']*old['humans']*old['zombies'] +
                      p['delta']*old['humans'] -
                      p['zeta']*old['corpses'])
   c
 end
end


# With the following parameters, humans are rapidly wiped out
# - this is inevitable where alpha < beta

exp1 = Population.new(10,0.01,500)
func1 = Orig.new( 
                  'alpha' => 0.005, 
                  'beta' => 0.0095, 
                  'zeta' => 0.0001, 
                  'delta' => 0.0001 )

func1.run( exp1, 2000 )

print "plotting\n"
exp1.plot

puts exp1
