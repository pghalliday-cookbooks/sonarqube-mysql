require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

# user permission was removed from template for 'anyone' (NULL)
describe command("mysql -usonar -psonar sonar -e \"SELECT COUNT(*) FROM perm_templates_groups WHERE group_id IS NULL AND permission_reference = 'user'\"") do
  it { should return_stdout(/0/) }
end

# codeviewer permission was not removed from template for 'anyone' (NULL)
describe command("mysql -usonar -psonar sonar -e \"SELECT COUNT(*) FROM perm_templates_groups WHERE group_id IS NULL AND permission_reference = 'codeviewer'\"") do
  it { should return_stdout(/1/) }
end

# issueadmin permission was removed from template for 'sonar-administrators' group
describe command("mysql -usonar -psonar sonar -e \"SELECT COUNT(*) FROM perm_templates_groups WHERE group_id IN (SELECT id FROM groups WHERE name = 'sonar-administrators') AND permission_reference = 'issueadmin'\"") do
  it { should return_stdout(/0/) }
end

# admin permission was not removed from template for 'sonar-administrators' group
describe command("mysql -usonar -psonar sonar -e \"SELECT COUNT(*) FROM perm_templates_groups WHERE group_id IN (SELECT id FROM groups WHERE name = 'sonar-administrators') AND permission_reference = 'admin'\"") do
  it { should return_stdout(/1/) }
end

# issueadmin permission was added only once to template for 'anyone' (NULL)
describe command("mysql -usonar -psonar sonar -e \"SELECT COUNT(*) FROM perm_templates_groups WHERE group_id IS NULL AND permission_reference = 'issueadmin'\"") do
  it { should return_stdout(/1/) }
end

# user permission was added only once to template for 'sonar-users' group
describe command("mysql -usonar -psonar sonar -e \"SELECT COUNT(*) FROM perm_templates_groups WHERE group_id IN (SELECT id FROM groups WHERE name = 'sonar-users') AND permission_reference = 'user'\"") do
  it { should return_stdout(/1/) }
end
