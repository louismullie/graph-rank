require_relative '../lib/graph-rank'
require 'rspec'

describe GraphRank::Keywords do
  
  before do 
    @text = 'The relentless march of three-dimensional printing continues. What started as a way of making prototypes by depositing layers of material in a manner reminiscent of inkjet printing is now becoming a real industrial technique. But it is also popular with hobbyists of the maker movement of small-scale amateur inventors.

    One thing makers would dearly love to do is cheaply ape the recently developed ability to print electrical circuits with sophisticated and costly machines. And a project led by Simon Leigh and his colleagues at the University of Warwick, in Britain, the results of which have just been published in the Public Library of Science, may let them do just that.

    Industrial-scale printing of 3D electrical circuits is still experimental. It uses exotic inks based on silver and carbon nanotubes. Dr Leigh has managed something similar with a hobbyist\'s printer and ink made of carbon black and polyester.

    Carbon black is, basically, a flashy name for soot. It is made by the incomplete combustion of heavy petroleum products such as tar. It is, though, electrically conductive. By adding granules of polyester Dr Leigh creates the uncooked version of a material he calls carbomorph. The cooked version is what is extruded by his printer, a commercially available machine of the type beloved by makers.

    This particular type of 3D printer works by extruding a thin, molten filament of material from a heated nozzle, to build up the object of desire in a way similar to making a coil pot out of a long, thin piece of clay. Carbomorph, because of its polyester component which melts when heated, is a suitable raw material for this process.

    It is also a useful one, for among its electrical properties is piezoresistivity. This means that if it is subjected to a mechanical stress, such as bending, its resistance increases. And that lets it modulate a current, and thus a signal.

    To test this idea, the researchers printed a plastic exoskeleton, containing strips of carbomorph, that can be attached to a glove. As the glove\'s wearer flexes his fingers, his movements can be followed by monitoring changes in the strips\' resistivity. Dr Leigh\'s initial thought was that this might be used to monitor the recovery of those who had suffered paralysing injuries to their hands, but it could have many other uses. Suitably interpreted, the signal from the exoskeleton might, for example, let someone pick things up remotely, with a hand-shaped grab - which could be a good idea if the things in question were heavy or dangerous.

    Carbomorph can also be used for capacitive sensing, the principle behind the trackpads on laptop computers as well as some touchscreens. Touching an area of carbomorph with your finger changes the local capacitance in a way that is easily detectable by an appropriate electrical circuit. Though Dr Leigh cannot yet print this circuit itself, it is easy to make one using an Arduino chip - a low-cost open-source device that is also popular with makers. In this way he has printed a computer-game controller that uses carbomorph in its buttons. That means makers who also like to play computer games can now indulge in two hobbies for the price of one.'
  end
  
  it "should find the right main keyword" do
    tr = GraphRank::Keywords.new
    ranks = tr.run(@text)
    ranks[0][0].should eql 'carbomorph'
  end

end