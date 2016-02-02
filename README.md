Merlin UI
====

A Sinatra app, for Merlin.

Go!
===

Download and run sinatra-bootstrap:

    git clone https://github.ibm.com/Bluemix/merlin-ui
    
    cd merlin-ui
    bundle install             # To install sinatra
    
    bundle exec ruby app.rb    # To run the sample
	
Then open [http://localhost:4567/](http://localhost:4567/)

Configuration
===

Update the `manifest.yml` with FourSquare API keys and a Google maps JavaScript API key.

Then just `cf push`

