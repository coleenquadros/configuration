<font size=24> Glitchtip </font>
---

[toc]

# Onboarding new Glitchtip Instance

* Enter a shell into glitchtip pod of the new instance
* Create Django admin user for the admin webinterface
  ```shell
  /code$ python manage.py createsuperuser
  Email: sd-app-sre+glitchtip-admin@redhat.com
  Password:
  Password (again):
  Superuser created successfully.
  ```
* Enter django admin interface and create an [automation account](https://glitchtip.stage.devshift.net/admin/users/user/add/) `sd-app-sre+glitchtip@redhat.com` with a random password. The integration will use a token instead of this password later.
* [Create](https://glitchtip.stage.devshift.net/admin/organizations_ext/organization/add/) an `app-sre-init` organization. The integration needs a bootstrapping organization, and it will delete this organization as soon as other organizations are configured.
* Add the automation account to the `app-sre-init` organization by [creating an organization user](https://glitchtip.stage.devshift.net/admin/organizations_ext/organizationuser/add/). Choose `owner` as role!
* Finally, [create an API token](https://glitchtip.stage.devshift.net/admin/api_tokens/apitoken/add/) for the automation user and enable all scopes except `event:***`.
* Store the token in [vault](https://vault.devshift.net/)
* Create a new glitchtip-instance file (example [glitchtip-stage](data/dependencies/glitchtip/glitchtip-stage.yml)).

# Notes

The qontract-reconcile glitchtip integration manages organizations where the automation account (e.g., `sd-app-sre+glitchtip@redhat.com`) has the owner role! Glitchtip doesn't have the global admin concept; an organization's role handles the permissions. The integration can see other organizations and, therefore, can't control those.
