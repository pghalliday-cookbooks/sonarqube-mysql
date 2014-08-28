def whyrun_supported?
  true
end

use_inline_resources

def mysql_connection_info
  sonarqube_mysql_mysql_host = node['sonarqube-mysql']['mysql']['host']
  sonarqube_mysql_mysql_username = node['sonarqube-mysql']['mysql']['username']
  sonarqube_mysql_mysql_password = node['sonarqube-mysql']['mysql']['password']

  {
    host: sonarqube_mysql_mysql_host,
    username: sonarqube_mysql_mysql_username,
    password: sonarqube_mysql_mysql_password
  }
end

action :add do
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
