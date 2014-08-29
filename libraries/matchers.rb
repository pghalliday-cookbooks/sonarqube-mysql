if defined?(ChefSpec)
  def add_sonarqube_mysql_group_permission_template_entry(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sonarqube_mysql_group_permission_template_entry, :add, resource_name)
  end

  def remove_sonarqube_mysql_group_permission_template_entry(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sonarqube_mysql_group_permission_template_entry, :remove, resource_name)
  end

  def update_sonarqube_mysql_user_password(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sonarqube_mysql_user_password, :update, resource_name)
  end
end
