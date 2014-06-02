# Nominet EPP

Ruby interface to the [Nominet EPP][http://www.nominet.org.uk/registrars/systems/nominetepp] registrar interface.

## Initialise a client

    require 'nominet-epp'
    client = NominetEPP::Client.new('TAGNAME', 'password')
    testclient = NominetEPP::Client.new('TAGNAME', 'password', 'testbed-epp.nominet.org.uk')

## Note on Patches/Pull Requests
 
  * Fork the project.
  * Make your feature addition or bug fix.
  * Add tests for it. This is important so I don't break it in a
    future version unintentionally.
  * Commit, do not mess with rakefile, version, or history.
    (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
  * Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Geoff Garside (M247 Ltd). See LICENSE for details.
