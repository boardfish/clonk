# Clonk

This is a gem that'll help you seed an instance of Red Hat SSO. Right now, it's still a work-in-progress, but it shouldn't be long before it's got everything I think it needs.

It makes some assumptions about what's in your environment at the moment, using `dotenv`. While developing, I'm keeping the following variables in there.

```
SSO_REALM="master"
SSO_BASE_URL="http://localhost:8080/auth"
SSO_USERNAME="user"
SSO_PASSWORD="password"
```

It's recommended to spin up an SSO instance alongside this to see what effects you're having on it. Here, it's important that the `preview` profile is used, so that we can use the `realm-management` client to take care of permissions in the realm.

```
docker run --rm -p 8080:8080 -e JAVA_OPTS_APPEND="-Dkeycloak.profile=preview" -e SSO_ADMIN_USERNAME=user -e SSO_ADMIN_PASSWORD=password registry.access.redhat.com/redhat-sso-7/sso72-openshift
```

## Usage

Clonk exposes SSO objects as ActiveRecord-esque models. As a short demonstration:

```
2.5.1 :003 > Clonk::Group.all
 => [#<Clonk::Group:0x00007fe7139ecda0 @name="another-test", @id="42b28060-7f4f-4b6d-82fd-6af031881a9e", @realm="master">, #<Clonk::Group:0x00007fe713808228 @name="chaos-chaos", @id="05af3f68-44d6-4973-8834-e957822e43ef", @realm="master">]
2.5.1 :004 > Clonk::Group.all.first.config
 => {"id"=>"42b28060-7f4f-4b6d-82fd-6af031881a9e", "name"=>"another-test", "path"=>"/another-test", "attributes"=>{}, "realmRoles"=>[], "clientRoles"=>{}, "subGroups"=>[], "access"=>{"view"=>true, "manage"=>true, "manageMembership"=>true}}
```

`Group.all` casts all groups in the realm to `Clonk::Group` objects...

...but you can access their plain JSON config with `Group#config`.

(So far, groups are all I've got, but everything else is in the process of being structured like this, and it's all sitting in `lib/clonk.rb`.)

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
