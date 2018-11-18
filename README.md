# Clonk

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
