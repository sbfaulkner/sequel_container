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
      contains :avatar, :url => '/images/avatars/:id.:extension'
    end

## CHANGES

### 1.2.0

- added assignment method
- automatically store image width and height for image content types

### 1.1.0

- added support for :url option on contains to specify custom url path

## TODO

- support for assignment other than from rack/sinatra?
- other containment types... e.g. filesystem, s3, git?

## Legal

**Author:** S. Brent Faulkner <brentf@unwwwired.net>
**License:** Copyright &copy; 2009 unwwwired.net, released under the MIT license
