require 'gnuplot'

class Population
 def initialize( people )
   @time = [ 0.0 ]
   @state = {}
   s['humans'] = [ people.to_f ]
 end

 def plot
   Gnuplot.open do |gp|
     Gnuplot::Plot.new( gp ) do |plot|
  
       plot.xrange "[0:#{time.last}]"
       plot.title  "Zombie Attack"
       plot.ylabel "Population"
       plot.xlabel "time"
    
       plot.data << Gnuplot::DataSet.new( [time,s['zombies'] ] ) do |ds|
         ds.title = "Zombies"
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
    
 def to_s
   out=""
   s.each do |var,history| 
     out << "#{var}: #{history.last}\n"
   end
   out
 end

 def s ; @state ; end

 def [] ( var )
   history = s[var]
   if ( history == nil )
     history = Array.new
     history << 0.0
     s[var] = history
   end
   history.last
 end

 attr_accessor :humans,:zombies,:corpses, :time
 
end

class Model
 def initialize( dt, params )
   @params = params
   @dt = dt
 end

 def p ; @params ; end

 def step( pop )
   deltas = change(pop)
   pop.s.each do |var,history|
     history << history.last + deltas[var]
   end
   pop.time << pop.time.last + @dt
   pop
 end
end

class Orig < Model

 def change( old )
   c = Hash.new
   c['humans'] = -@dt*p['beta']*old['humans']*old['zombies']
   c['zombies'] = @dt*(p['beta']*old['humans']*old['zombies'] -
                      p['alpha']*old['humans']*old['zombies'] +
                      p['zeta']*old['corpses'])
   c['corpses'] = @dt*(p['alpha']*old['humans']*old['zombies'] +
                      p['delta']*old['humans'] -
                      p['zeta']*old['corpses'])
   c
 end
end

class Mine < Model
  def change( old )
    c = Hash.new

    newzombies = (old.time.length==50)?20:0;

    c['humans'] = -@dt*p['beta']*old['humans']*old['zombies']
    c['zombies'] = @dt*(p['beta']*old['humans']*old['zombies'] -
                        p['alpha']*old['humans']*old['zombies'] +
                        p['zeta']*old['corpses'] +
                        newzombies )
    c['corpses'] = @dt*(p['alpha']*old['humans']*old['zombies'] +
                        p['delta']*old['humans'] -
                        p['zeta']*old['corpses'] -
                        p['lambda']*old['corpses'])
    c
 end
end


def run( pop, func, steps )
  steps.times do
    func.step( pop )
  end
  pop
end

exp1 = Population.new(500)
func1 = Orig.new( 0.01,
                  'alpha' => 0.005, 
                  'beta' => 0.0095, 
                  'zeta' => 0.0001, 
                  'delta' => 0.0001 )

func2 = Mine.new( 1,
                  'alpha' => 0.01, 
                  'beta' => 0.0095, 
                  'zeta' => 0.0001, 
                  'delta' => 0.001,
                  'lambda' => 0.01 )
#func2 = Mine.new( 0.01, 0.0095, 0.0001, 0.001, 0.01, 1 )


run( exp1, func2, 2000 )
exp1.plot
puts exp1

