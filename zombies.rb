require 'gnuplot'

class Population
 def initialize( people )
   @humans = [ people.to_f ]
   @zombies = [ 0.0 ]
   @corpses = [ 0.0 ]
   @time = [ 0.0 ]
 end

 def plot
   Gnuplot.open do |gp|
     Gnuplot::Plot.new( gp ) do |plot|
  
       plot.xrange "[0:#{time.last}]"
       plot.title  "Zombie Attack"
       plot.ylabel "Population"
       plot.xlabel "time"
    
       plot.data << Gnuplot::DataSet.new( [time,zombies] ) do |ds|
         ds.title = "Zombies"
         ds.with = "lines lc rgb \"red\""
         ds.linewidth = 2
       end

       plot.data << Gnuplot::DataSet.new( [time,humans] ) do |ds|
         ds.title = "Humans"
         ds.with = "lines lc rgb \"blue\""
         ds.linewidth = 2
         ds
       end
       
     end
   end
 end
    
 def to_s
   return "Humans: #{humans.last}\nZombies:#{zombies.last}\nCorpses:#{corpses.last}"
 end

 attr_accessor :humans,:zombies,:corpses, :time
end

class Orig
 def initialize( alpha, beta, zeta, delta, dt )
   @a = alpha
   @b = beta
   @z = zeta
   @d = delta
   @dt = dt
 end

 def step( pop )
   h = pop.humans.last
   z = pop.zombies.last
   c = pop.corpses.last

   pop.humans << h + @dt*(-@b*h*z)
   pop.zombies << z + @dt*(@b*h*z - @a*h*z + @z*c)
   pop.corpses << c + @dt*(@a*h*z + @d*h - @z*c)

   pop.time << pop.time.last + @dt

   pop
 end
end

class Mine
 def initialize( alpha, beta, zeta, delta, lambda, dt )
   @a = alpha
   @b = beta
   @z = zeta
   @d = delta
   @l = lambda
   @dt = dt
 end

 def step( pop )
   h = pop.humans.last
   z = pop.zombies.last
   c = pop.corpses.last

   newzombies = (pop.time.length==50)?20:0;

   pop.humans << h + @dt*(-@b*h*z)
   pop.zombies << z + @dt*(@b*h*z - @a*h*z + @z*c) + newzombies
   pop.corpses << c + @dt*(@a*h*z + @d*h - @z*c - @l*c)

   pop.time << pop.time.last + @dt

   pop
 end
end


def run( pop, func, steps )
  steps.times do
    func.step( pop )
  end
  pop
end

exp1 = Population.new(500)
func1 = Orig.new( 0.005, 0.0095, 0.0001, 0.0001, 0.01 )
func2 = Mine.new( 0.01, 0.0095, 0.0001, 0.001, 0.01, 1 )


run( exp1, func2, 2000 )
exp1.plot
puts exp1
