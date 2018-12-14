# frozen_string_literal: true

require 'clonk'
sso = Clonk::Connection.new(
  base_url: 'http://sso:8080',
  realm_id: 'master',
  username: 'user',
  password: 'password',
  client_id: 'admin-cli'
)
sso.realm = sso.create_realm(realm: 'marauders-map')
users = []
%i[rlupin hpotter ddursley].each do |username|
  user = sso.create_user(username: username)
  users << user
  sso.set_password_for(user: user, password: 'Password123')
end
marauders_map = sso.create_client(clientId: 'marauders-map')
marauder_role = sso.create_role(client: marauders_map, name: 'Marauder', description: 'Solemnly swears they\'re up to no good')
hogwarts = sso.create_group(name: 'Hogwarts')
students = sso.create_subgroup(group: hogwarts, name: 'Students')
sso.add_to_group(user: sso.users.find { |u| u.username == 'hpotter' }, group: students)
marauders = sso.create_subgroup(group: hogwarts, name: 'Marauders')
sso.add_to_group(user: sso.users.find { |u| u.username == 'rlupin' }, group: marauders)
sso.map_role(target: marauders, role: marauder_role)
