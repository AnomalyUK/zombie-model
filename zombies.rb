
# captures the history of a population of humans and zombies over time
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

 def scale( arr, mult )
   arr.collect { |x| mult*x }
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


# Base class for evolving a Population
class Model
 def initialize( params )
   @params = params
 end

 def p ; @params ; end

 def max(f1,f2) ; (f1>f2)?f1: f2 ; end

 def step( pop )
   update = Hash.new
   deltas = change(pop)
   deltas.each do |var,delta|
     update[var] = max(pop[var] + delta,0.0)
   end
   pop << update
   deltas
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
   
 def run( pop, steps )
   steps.times do |x|
     moves = step( pop )
     print "time\t#{x} x #{pop.dt}\n#{pop}\n" if ( x%25000 == 0 )
   end
   pop
 end
end


