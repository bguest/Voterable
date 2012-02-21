Voterable
=========

About
-----

This is a mongoid dependant gem that adds voteable charactistics to voteable things and the voters that can vote on these things.

It's my first gem, and quite honestly it's probably not the right way to do things, but it's working great for me, so knock yourself out if you need something more robust than voteable_mongo.

Dependencies
------------

- Mongoid (2.3.0+)

Useage
======

To add a class that can vote on something (in this case a User), subclass your user from Voterable::Voter

    class User < Voterable::Voter
    ...
    end

To add a class that can be voted on (in this case a thing), subclass the thing from Voterable::Voteable

    class Thing < Voterable::Voteable
    ...
    end


Because I'm pretty much assuming that the only person that is using this is me, for now, you can look through the source to figure out how things work. If you want me to do a better job documenting stuff, email me and I'll start working on it

Migration 
=========

0.0.X to 0.1.X
---------------

   $ rake migrate_to_0_1_X

-Tata for now
-Ben