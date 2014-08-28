require_relative '../spec_helper'

mysql_connection_info = {
  host: 'localhost',
  username: 'root',
  password: 'root'
}

describe 'sonarqube-mysql::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'should configure the sonar database' do
    expect(chef_run).to include_recipe('database::mysql')

    expect(chef_run).to create_mysql_database_user('sonar').with(
      connection: mysql_connection_info,
      password: 'sonar'
    )

    expect(chef_run).to create_mysql_database('sonar').with(
      connection: mysql_connection_info
    )

    expect(chef_run).to grant_mysql_database_user('sonar').with(
      connection: mysql_connection_info,
      password: 'sonar',
      database_name: 'sonar',
      host: '%',
      privileges: [:all]
    )
  end
end
