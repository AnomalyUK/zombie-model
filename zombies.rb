require 'gnuplot'

class Population
 def initialize( skip, dt, people )
   @time = Array.new
   @state = {}
   @now = {}
   @skipcount = 0
   @skip = skip
   @dt = dt
   @clock = 0.0
   @now['humans'] = people.to_f
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
   val = @now[var]
   if val == nil
     val = 0.0
     @now[var] = val
   end
   val
 end

 def << ( state )
   @now = state
   if @skipcount == 0
     now.each do |var,val|
       s[var] = Array.new if s[var] == nil
       s[var] << val
     end
     @time << @clock
     @skipcount = @skip
   end
   @skipcount -= 1

   @clock += dt
   
   self
 end

 attr_accessor :time,:now
 attr_reader :dt,:clock
end

class Model
 def initialize( params )
   @params = params
 end

 def p ; @params ; end

 def step( pop )
   update = Hash.new
   deltas = change(pop)
   deltas.each do |var,delta|
     update[var] = pop[var] + delta
   end
   pop << update
 end

 def at( pop, t )
   if ( (t - pop.clock).abs < (pop.dt/2.0) )
     yield
   end
 end

 def every( pop, t )
   times = ( pop.clock / t ).to_i
   rem = pop.time.last - ( times * t )
   if ( rem.abs < (pop.dt/2) )
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
    dt = old.dt

    c['humans']  = dt*(-p['beta']*old['humans']*old['zombies'] +
                      p['pi']*old['humans'])
    c['zombies'] = dt*(p['beta']*old['humans']*old['zombies'] -
                       p['alpha']*old['humans']*old['zombies'] +
                       p['zeta']*old['corpses'] )
    c['corpses'] = dt*(p['alpha']*old['humans']*old['zombies'] +
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

exp1 = Population.new(1000,0.02,500)
func1 = Orig.new( 
                  'alpha' => 0.005, 
                  'beta' => 0.0095, 
                  'zeta' => 0.0001, 
                  'delta' => 0.0001 )

func2 = Mine.new( 'alpha' => 0.01, 
                  'beta' => 0.0096, 
                  'zeta' => 0.0001, 
                  'delta' => 0.001,
                  'lambda' => 0.01,
                  'epsilon' => 10,
                  'pi' => 0.00025 )

def test(e,f)
#  ch1 = f.change( e )
#  puts ch1

  up = f.step( e )
  puts e.now
  up = f.step( e )
  puts e.now
  up = f.step( e )
  puts e.now
  up = f.step( e )
  puts e.now

  puts e.time
end

#test(exp1,func2)
#exit

run( exp1, func2, 200000 )
print "plotting\n"
#exp1.clip(850,855,0.05)
exp1.plot
puts exp1

