# Clonk [![Gem Version](https://badge.fury.io/rb/clonk.svg)](https://badge.fury.io/rb/clonk)

This is a gem that'll help you seed an instance of Red Hat SSO or Keycloak.

You should initialize the following environment variables. They aren't used by Clonk, but your Red Hat SSO instance will need them to create an admin user.

```
SSO_ADMIN_USERNAME
SSO_ADMIN_PASSWORD
```

It's recommended to spin up an SSO instance alongside this to see what effects you're having on it. Here, it's important that the `preview` profile is used, so that we can use the `realm-management` client to take care of permissions in the realm.

```
docker run --rm -p 8080:8080 -e JAVA_OPTS_APPEND="-Dkeycloak.profile=preview" -e SSO_ADMIN_USERNAME=user -e SSO_ADMIN_PASSWORD=password registry.access.redhat.com/redhat-sso-7/sso72-openshift
```

You're also able to use Keycloak, but additional configuration may be required to use permissions, policies and other features.

## Usage

### Authenticating with SSO

To authenticate with SSO, create a connection. You'll use this to interface with SSO. This is done in the demo seed script as follows:

```
sso = Clonk::Connection.new(
  base_url: 'http://sso:8080',
  realm_id: 'master',
  username: 'user',
  password: 'password',
  client_id: 'admin-cli'
)
```

This will retrieve an access token against the realm whose ID you supplied. However, you can change the realm used by the connection by supplying a new `realm` object to the connection. Create a new realm to play with...

```
sso.realm = sso.create_realm(realm: 'marauders-map')
```

...or use an existing one.

```
sso.realm = sso.realms.first
```


### Interfacing with SSO

Clonk exposes SSO objects as ActiveRecord-esque models. You're also able to view all attributes each object has in SSO using the `config` method. As a short demonstration:

```
irb(main):022:0> sso.groups
=> [#<Clonk::Group:0x000055ea7e812ef0 @name="McCree", @id="b72aa189-f188-433a-a05c-b89bb46e62a3">, #<Clonk::Group:0x000055ea7e812ec8 @name="Sombra", @id="f5edda09-4c39-43c3-bde4-5a32a079f58a">, #<Clonk::Group:0x000055ea7e812ea0 @name="bar", @id="6683dcb7-18ae-4695-bf93-5a4b2c8e8bc9">, #<Clonk::Group:0x000055ea7e812e78 @name="foo", @id="7f4826c8-85e4-4a7b-aa52-b162ef286d59">]
irb(main):023:0> sso.config(sso.groups.first)
=> {"id"=>"b72aa189-f188-433a-a05c-b89bb46e62a3", "name"=>"McCree", "path"=>"/McCree", "attributes"=>{}, "realmRoles"=>[], "clientRoles"=>{}, "subGroups"=>[{"id"=>"f8dbfe41-1165-4d21-9d4e-62a5f89c5abf", "name"=>"Roadhog", "path"=>"/McCree/Roadhog", "attributes"=>{}, "realmRoles"=>[], "clientRoles"=>{}, "subGroups"=>[]}], "access"=>{"view"=>true, "manage"=>true, "manageMembership"=>true}}
```

`groups` casts all groups in the realm to `Clonk::Group` objects...

...but you can access their plain JSON config with `Clonk::Connection#config`.

There are plenty of methods you can use that wrap the API very nicely – you're able to create and interface with a variety of objects in SSO.

Documentation is available on [RubyGems](https://www.rubydoc.info/gems/clonk).

## Why?

When developing against Red Hat SSO and Keycloak, I've personally struggled to deal with the documentation. There are a lot of assumptions that are made about what you know and what you don't. So I've made this gem...

### ...to help devs use SSO platforms with their Rails apps

Sometimes, Devise just doesn't cut it, especially if you want to allow users to sign into multiple apps with the same credentials. Running a SSO instance that all your apps can call off to can make things more flexible!

### ...to document API endpoints that are documented either confusingly or not at all

SSO is a huge project, so it's sort of understandable that perhaps its documentation isn't too easy to understand at first glance...especially if you've never used an SSO backend before. Some API endpoints that'll be used in this gem aren't even documented.

### ...to better integrate Ruby/Rails with SSO

I guess this comes back to the first one. SSO integration with Rails apps could be really powerful. Especially if it's wrapped in that familiar ActiveRecord style.

### ...to make seeding SSO a lot more readable in future

I seeded SSO with more `curl` requests than you could shake a stick at. Suffice to say, it didn't look like the prettiest piece of code...

### ...to transfer what I've learned

This gem goes hand-in-hand with a blog post I'm writing, but I'm hoping it'll go further than just that tutorial. Fingers crossed this gem will have its tendrils deep in a lot of SSO instances out there...which sounds a little ominous, but...yeah, you get the gist!

## Development

I've built a containerised environment for this.

To bring up your SSO instance on port 8080: `docker-compose up -d sso`

To run the seed script: `docker-compose run --rm seeder ruby seed_script.rb`

To run the test suite: `docker-compose run --rm seeder rspec`

To run a development console: `gem build clonk.gemspec; docker-compose build seeder; docker-compose run --rm seeder rspec`

Once you're in the dev console, `require 'clonk'` and you can get started playing with methods. Note that the version of `clonk` that is used is defined in the `Dockerfile.`

The structure of the project is as follows:

- Methods that don't require authentication in SSO should be in the top-level module. This is due to change, as `Clonk::Connection` objects will be able to be initialised without credentials.
- Each file under `lib/clonk` defines a class representation of an object in SSO, and methods on a `Connection` object to be able to interface with it.

## FAQ/Common Issues

### Error 400

Bad request – you may be sending bad parameters.

### Error 401

This means your token has expired or you're providing the wrong credentials. You'll need to reinitialise your `Clonk::Connection` object to retrieve a new one.

### Error 403

The user you have authenticated as does not have permission to access the current object.

### Error 404

The object you're looking for wasn't found and may not exist in SSO.
