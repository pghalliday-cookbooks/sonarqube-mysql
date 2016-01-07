def whyrun_supported?
  true
end

use_inline_resources

def mysql_connection_info
  {
    host:     node['sonarqube-mysql']['mysql']['host'],
    username: node['sonarqube-mysql']['username'],
    password: node['sonarqube-mysql']['password'],
    socket:   node['sonarqube-mysql']['mysql']['socket']
  }
end

def retry_server(message, attempts)
  Chef::Log.info("Waiting for server: #{message}")
  sleep(5)
  wait_for_server(attempts - 1)
end

def wait_for_server(attempts)
  fail 'Timed out waiting for server' if attempts == 0
  uri = URI("#{node['sonarqube-mysql']['sonarqube']['url']}/api/server?format=json")
  begin
    response = Net::HTTP.get(uri)
    status = JSON.parse(response)['status']
    retry_server("status: #{status}", attempts) unless status == 'UP'
  rescue => e
    retry_server(e.message, attempts)
  end
end

action :update do
  wait_for_server(36)

  mysql_database 'sonar' do
    connection mysql_connection_info
    sql <<-EOH
      UPDATE users
      SET
        crypted_password = '#{new_resource.crypted_password}',
        salt = '#{new_resource.salt}'
      WHERE login = '#{new_resource.login}'
    EOH
    action :query
  end
end
