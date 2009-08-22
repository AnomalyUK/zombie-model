require 'gnuplot'

class Population
 def initialize( people )
   @time = [ 0.0 ]
   @state = {}
   @now = {}
   s['humans'] = [ people.to_f ]
 end

 def plot
   Gnuplot.open do |gp|
     Gnuplot::Plot.new( gp ) do |plot|
  
       plot.xrange "[#{time.first}:#{time.last}]"
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
       
       if false
         ratio=[]
         s['humans'].each_with_index do |h,i|
           ratio << s['zombies'][i] * 10.0
         end
         plot.data << Gnuplot::DataSet.new( [time,ratio ] ) do |ds|
           ds.title = "Product"
           ds.with = "lines lc rgb \"black\""
           ds.linewidth = 1
           ds
         end
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

 def clip( from, to, dt )
   x1 = from/dt
   x2 = to/dt
   @time = @time[x1..x2]
   @state.each do |var,arr|
     @state[var] = arr[x1..x2]
   end
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

 attr_accessor :time,:now
 
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
     newval = history.last + deltas[var]
     newval = 0.0 if newval < 0.0
     history << newval
   end
   pop.time << pop.time.last + @dt
   pop
 end

 def at( pop, t )
   if ( (t - pop.time.last).abs < (@dt/2.0) )
     yield
   end
 end

 def every( pop, t )
   times = ( pop.time.last / t ).to_i
   rem = pop.time.last - ( times * t )
   if ( rem.abs < (@dt/2) )
     yield
   end
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

    c['humans'] = @dt*(-p['beta']*old['humans']*old['zombies'] +
                       p['pi']*old['humans'])
    c['zombies'] = @dt*(p['beta']*old['humans']*old['zombies'] -
                        p['alpha']*old['humans']*old['zombies'] +
                        p['zeta']*old['corpses'] )
    c['corpses'] = @dt*(p['alpha']*old['humans']*old['zombies'] +
                        p['delta']*old['humans'] -
                        p['zeta']*old['corpses'] -
                        p['lambda']*old['corpses'])

    at( old, 5 ) { c['zombies'] = c['zombies'] + p['epsilon']}

    c
 end
end


def run( pop, func, steps )
  steps.times do |x|
    func.step( pop )
    print "#{x}\t#{pop['humans']}\n" if ( x%25000 == 0 )
  end
  pop
end

exp1 = Population.new(500)
func1 = Orig.new( 0.01,
                  'alpha' => 0.005, 
                  'beta' => 0.0095, 
                  'zeta' => 0.0001, 
                  'delta' => 0.0001 )

func2 = Mine.new( 0.02,
                  'alpha' => 0.01, 
                  'beta' => 0.0096, 
                  'zeta' => 0.0001, 
                  'delta' => 0.001,
                  'lambda' => 0.01,
                  'epsilon' => 10,
                  'pi' => 0.00025 )

run( exp1, func2, 200000 )
print "plotting\n"
#exp1.clip(850,855,0.05)
exp1.plot
puts exp1

