require 'zombies'

# as Orig, but destroyed zombies are not corpses, and corpses
# rot away at rate lambda.
#
# also allows zombies to be injected according to a schedule
class Rotting < Model
  def change( old )
    c = Hash.new
    dt = old.dt

    c['humans']  = dt*(-p['beta']*old['humans']*old['zombies'] +
                      p['pi']*old['humans'])
    c['zombies'] = dt*(p['beta']*old['humans']*old['zombies'] -
                       p['alpha']*old['humans']*old['zombies'] +
                       p['zeta']*old['corpses'] )
    c['corpses'] = dt*(p['delta']*old['humans'] -
                       p['zeta']*old['corpses'] -
                       p['lambda']*old['corpses'])

    if p['zombies_in']
      p['zombies_in'].each do |entry|
        at( old, entry[0] ) do
          var = entry[1]
          c[var] = ( c[var] + (entry[2] * old[var]) + entry[3] ) 
        end
      end
    end
    c
 end
end
