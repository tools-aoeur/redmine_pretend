# Pretend Plugin for Redmine

*Redmine plugin for quickly switching user accounts*

When you're an admin solving user problems, you often hear: "It's not working". The best way to verify this is to log in as the user, but you don't know their password.

This plugin solves that problem:
If you have an admin role, you can go to any user's account page and press the "Pretend" button.
You will then be logged in as that selected user.
When you're finished, you can always return to your account by pressing "Stop Pretending" at the top of the page.

Supports Redmine >= 6.1

## Install

* Extract the plugin into the plugins directory
* Restart Redmine

## Behaviour

* Only a logged-in admin can pretend; anyone else gets a 403 and the session is left untouched.
* While pretending, further "Pretend" requests (double click, stale tab) are ignored and redirect back, so impersonations never nest.
* The real user is kept in `session[:real_user_id]` until "Stop Pretending".

## Tests

The specs use RSpec and live in `spec/`. From a Redmine checkout with the plugin installed:

```sh
bundle exec rails redmine:plugins:test NAME=redmine_pretend
```

The GitHub Actions workflow in `.github/workflows/6_1.yml` runs the same command.

## License

This software is under the [MIT License](http://www.opensource.org/licenses/MIT).
