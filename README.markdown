[![Build Status](https://travis-ci.org/fcheung/keychain.svg?branch=master)](https://travis-ci.org/fcheung/keychain)

A set of ruby bindings for the OS X keychain, written using ffi.

Installation
============

```
$ gem install ruby-keychain
```

or in your `Gemfile`:

```ruby
gem 'ruby-keychain', :require => 'keychain'
```

Introduction
============

The keychain is OS X's secure credential storage mechanism. This library allows access to internet passwords (typically specified as a combination of host, protocol, account (optionally port)) and generic passwords (identified by a service and account).


Working with keychains
==================

Most operations will act on either the default keychain, or the default keychain search list. You can obtain specific keychains with

```ruby
Keychain.default # the default keychain, usually /Users/<username>/Library/Keychains/<username>.keychain
Keychain.open(path) # opens a keychain file
Keychain.create(path, password) # creates a new keychain at the specified path, with the specified password
                                # omit the password to make the keychain prompt the user
```

Searching for Keychain Items
=============================

The top level constant `Keychain` as well as individual keychain objects have two methods `internet_passwords` and `generic_passwords` that return scope like objects. You can do

```ruby
Keychain.internet_passwords.where(:server => 'example.com').all
```

to return Keychain::Item objects for that server

```ruby
Keychain.internet_passwords.where(:server => 'example.com').first
```

to return the first Keychain::Item for that server or

```ruby
Keychain.internet_passwords.where(:server => 'example.com').limit(4).all
```

to return up to 4 Keychain::Item for that server.

`generic_passwords` behaves similarly but searches the keychain for genereric passwords

You can restrict the search to a specific keychain with

```ruby
some_keychain.internet_passwords.where(:server => 'example.com').all
```

returns matching `Keychain::Item` from the specified keychain.

or to an arbitrary list of keychains with

```ruby
Keychain.internet_passwords.in(keychain_1, keychain2).all
```

Finding a Keychain::Item won't prompt the user for a password if the keychain is unlocked. Calling the password accessor method of the item may prompt the user for their password depending on the keychain item access settings.

If you call `where` multiple times, each successive invocation merges its conditions with the previous set of conditions


Creating keychain items
=========================

In the default keychain:

```ruby
Keychain.internet_passwords.create(:server => 'example.com', :protocol => Keychain::Protocols::HTTP, :password => 'secret', :account => 'bob')

# or

Keychain.generic_passwords.create(:service => 'AWS', :password => 'secret', :account => 'bob')
```

In a specific keychain

```ruby
some_keychain.internet_passwords.create(...)
```

by default keychain items are only readable by the application that created them, however when running a ruby script the application is ruby: by default other ruby scripts will be able to read the items (if the keychain is unlocked).

Using keychain items
=====================

The `Keychain::Item` class has accessors for all its attributes, for the full list of attributes see [`Keychain::Item::ATTR_MAP`](https://github.com/fcheung/keychain/blob/master/lib/keychain/item.rb)

All strings returned are utf-8 encoded. Be careful not to set attribute values to strings with the ASCII_8BIT encoding as this will cause them to be treated as raw data rather than string. The exception to this is password data which the keychain api defines as being arbitrary binary data. When storing an actual password it is customary to use utf-8. The password data will always be returned as raw binary data


Error Handling
==============

Failed operations will result in `Keychain::Error` being raised. The original error code is available as the `code` attribute of the exception. When attempting to insert a duplicate item, `Keychain::DuplicateItemError` (a subclass of `Keychain::Error`) is raised instead


Compatibility
=============
Requires ruby 1.9 due to use of encoding related methods. Should work in MRI and jruby. Not compatible with rubinius due to rubinius' ffi implemenation
not supporting certain features
