include_recipe 'database::mysql'

sonarqube_mysql_username = node['sonarqube-mysql']['username']
sonarqube_mysql_password = node['sonarqube-mysql']['password']

sonarqube_mysql_mysql_host = node['sonarqube-mysql']['mysql']['host']
sonarqube_mysql_mysql_username = node['sonarqube-mysql']['mysql']['username']
sonarqube_mysql_mysql_password = node['sonarqube-mysql']['mysql']['password']

mysql_connection_info = {
  host: sonarqube_mysql_mysql_host,
  username: sonarqube_mysql_mysql_username,
  password: sonarqube_mysql_mysql_password
}

mysql_database_user sonarqube_mysql_username do
  connection mysql_connection_info
  password sonarqube_mysql_password
  action :create
end

mysql_database 'sonar' do
  connection mysql_connection_info
  action :create
end

mysql_database_user sonarqube_mysql_username do
  connection mysql_connection_info
  password sonarqube_mysql_password
  database_name 'sonar'
  host '%'
  privileges [:all]
  action :grant
end
