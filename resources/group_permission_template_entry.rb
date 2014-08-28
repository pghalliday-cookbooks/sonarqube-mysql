actions :add, :remove
default_action :add

attribute :permission_reference, name_attribute: true, kind_of: String
attribute :permission_template, kind_of: String, required: true
attribute :group, kind_of: String
