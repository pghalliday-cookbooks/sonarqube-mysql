require 'serverspec'

set :backend, :exec
set :path, '/bin:$PATH'

describe 'Sonarqube service' do
  describe port(9000) do
    it { should be_listening }
  end

  describe service('sonarqube') do
    it { should be_enabled }
    it { should be_running }
  end
end
