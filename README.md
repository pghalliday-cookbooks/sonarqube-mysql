# sonarqube-mysql

Configures a MySQL instance with a database and user for SonarQube. Provides LWRPs for managing sonar configuration held in the MySQL database.

## Notes

- See `test/integration/cookbooks/test` and `.kitchen.yml` for usage examples
- Ensure the correct SonarQube URL is set in the attributes
  - The LWRPs will use this to check the status of the server before trying to update any database tables
- Does not install SonarQube in case there are specific needs on your system
  - add `sonarqube::default` to your run list after `sonarqube-mysql::default` for a simple installation
    - remember to override the JDBC connection attributes to point to your MySQL database
  - it is necesarry to install and run SonarQube before calling the LWRPs as this populates the initial state of the database
- Does not install MySQL in case there are specific needs on your system
  - add `mysql::server` to your run list before `sonarqube-mysql::default` for a simple installation
- Does not run `apt::default` on Ubuntu
  - add `apt::default` to your run list before anything else if you're deploying on Ubuntu

## Contributing

### Prerequisites

- [ChefDK](http://downloads.getchef.com/chef-dk/ "ChefDK")
- Recent RuboCop

  ```
  chef gem install rubocop
  ```

### Testing

Test changes using

```
chef exec rake
chef exec kitchen verify
```


