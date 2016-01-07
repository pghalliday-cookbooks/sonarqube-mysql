include_recipe 'apt' if platform?('ubuntu')

mysql_initial_root_password = 'changeme'
mysql_service 'sonar' do
  port '3306'
  initial_root_password mysql_initial_root_password
  action [:create, :start]
end

node.override['sonarqube-mysql']['mysql']['host'] = 'localhost'
node.override['sonarqube-mysql']['mysql']['username'] = 'root'
node.override['sonarqube-mysql']['mysql']['password'] = mysql_initial_root_password
include_recipe 'sonarqube-mysql'

include_recipe 'java'

node.override['sonarqube']['jdbc']['username'] = node['sonarqube-mysql']['username']
node.override['sonarqube']['jdbc']['password'] = node['sonarqube-mysql']['password']
node.override['sonarqube']['jdbc']['url'] = 'jdbc:mysql://localhost:3306/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true'
include_recipe 'sonarqube'

sonarqube_mysql_group_permission_template_entry 'remove user from anyone' do
  permission_reference 'user'
  permission_template 'default_template'
  action :remove
end

sonarqube_mysql_group_permission_template_entry 'remove issueadmin from sonar-administrators' do
  permission_reference 'issueadmin'
  group 'sonar-administrators'
  permission_template 'default_template'
  action :remove
end

sonarqube_mysql_group_permission_template_entry 'add issueadmin to anyone' do
  permission_reference 'issueadmin'
  permission_template 'default_template'
  action :add
end

# This should not add another entry to the table
sonarqube_mysql_group_permission_template_entry 'add issueadmin again to anyone' do
  permission_reference 'issueadmin'
  permission_template 'default_template'
  action :add
end

sonarqube_mysql_group_permission_template_entry 'add user to sonar-users' do
  permission_reference 'user'
  group 'sonar-users'
  permission_template 'default_template'
  action :add
end

# This should not add another entry to the table
sonarqube_mysql_group_permission_template_entry 'add user again to sonar-users' do
  permission_reference 'user'
  group 'sonar-users'
  permission_template 'default_template'
  action :add
end

sonarqube_mysql_user_password 'admin' do
  crypted_password 'c69266c47cf046c59db184fd299f26051f1e8b30'
  salt '6522f3c5007ae910ad690bb1bdbf264a34884c6d'
end
