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

action :add do
  wait_for_server(36)

  group_id_field = new_resource.group ? 'group_id, ' : ''
  group_id_select = new_resource.group ? 'groups.id, ' : ''
  group_id_table = new_resource.group ? 'groups, ' : ''
  group_id_condition = new_resource.group ? "AND groups.name = '#{new_resource.group}'" : ''
  group_id_condition_2 = new_resource.group ? "IN (SELECT id FROM groups WHERE name = '#{new_resource.group}')" : 'IS NULL'

  mysql_database 'sonar' do
    connection mysql_connection_info
    sql <<-EOH
      INSERT INTO perm_templates_groups (#{group_id_field}template_id, permission_reference, created_at, updated_at)
      SELECT #{group_id_select}permission_templates.id, '#{new_resource.permission_reference}', NOW(), NOW()
      FROM #{group_id_table}permission_templates
      WHERE permission_templates.kee = '#{new_resource.permission_template}'
      #{group_id_condition}
      AND NOT EXISTS (
        SELECT 1
        FROM perm_templates_groups
        WHERE permission_reference = '#{new_resource.permission_reference}'
        AND group_id #{group_id_condition_2}
        AND template_id IN (
          SELECT id FROM permission_templates
          WHERE kee = '#{new_resource.permission_template}'
        )
      )
    EOH
    action :query
  end
end

action :remove do
  wait_for_server(36)

  group_id_condition = new_resource.group ? "IN (SELECT id FROM groups WHERE name = '#{new_resource.group}')" : 'IS NULL'

  mysql_database 'sonar' do
    connection mysql_connection_info
    sql <<-EOH
      DELETE FROM perm_templates_groups
      WHERE permission_reference = '#{new_resource.permission_reference}'
      AND group_id #{group_id_condition}
      AND template_id IN (
        SELECT id FROM permission_templates
        WHERE kee = '#{new_resource.permission_template}'
      )
    EOH
    action :query
  end
end
