actions :update
default_action :update

attribute :login, name_attribute: true, kind_of: String
attribute :crypted_password, kind_of: String, required: true
attribute :salt, kind_of: String, required: true
