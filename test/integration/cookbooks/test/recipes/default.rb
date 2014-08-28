include_recipe 'apt' if platform?('ubuntu')

node.override['mysql']['bind_address'] = '0.0.0.0'
node.override['mysql']['server_root_password'] = 'root'
include_recipe 'mysql::server'

node.override['sonarqube-mysql']['mysql']['host'] = 'localhost'
node.override['sonarqube-mysql']['mysql']['username'] = 'root'
node.override['sonarqube-mysql']['mysql']['password'] = node['mysql']['server_root_password']
include_recipe 'sonarqube-mysql'

include_recipe 'java'

node.override['sonarqube']['jdbc']['username'] = node['sonarqube-mysql']['username']
node.override['sonarqube']['jdbc']['password'] = node['sonarqube-mysql']['password']
node.override['sonarqube']['jdbc']['url'] = 'jdbc:mysql://localhost:3306/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true'
include_recipe 'sonarqube'
