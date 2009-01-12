# sequel\_container

contained documents (i.e. attachments) for sequel models

## WHY?

I needed a way to more easily support images and css in blobs, since the hosting provider I'm using is read-only (except for the tmp folder) and I'm not ready to use Amazon, or any other external storage provider.

## Installation

Run the following if you haven't already:

    $ gem sources -a http://gems.github.com
  
Install the gem(s):

    $ sudo gem install -r sbfaulkner-sequel_container

## Example

    require 'rubygems'
    require 'sequel'
    
    class User < Sequel::Model
      set_schema do
        primary_key :id
        varchar :avatar_type, :size => 255
        bytea :avatar_data
      end
      is :container, :tmp => File.dirname(__FILE__) + '/tmp'
      contains :avatar
    end
    
## TODO

- remove frozen copy sequel gem when updateis released
- include logic for image width and height
- better assignment support (i.e. don't require separate assignment of type and data)
- publish in sequel www/pages/plugins
- other containment types... e.g. filesystem, s3, git?

## Legal

**Author:** S. Brent Faulkner <brentf@unwwwired.net>  
**License:** Copyright &copy; 2009 unwwwired.net, released under the MIT license
