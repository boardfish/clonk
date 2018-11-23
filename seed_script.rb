require 'clonk'
Clonk::Realm.create(name: ENV.fetch('SSO_REALM'))
%i[rlupin hpotter ddursley].each do |username|
  user = Clonk::User.create(username: username)
  # user.map_role(role: ???)
  user.set_password(password: 'Password123')
end
marauders_map = Clonk::Client.create(name: 'marauders-map')
# secret_client = Clonk::Client.create(name: 'secret_client', public_client: false, dag_enabled: false)
# Clonk::Policy.create(
#   name: 'target-client-exchange',
#   description: 'Policy to enable token exchange between a client and this one'
#   type: :client,
#   objects: [secret_client]
# )
# TODO: write example to assign permission to that client
marauder_role = marauders_map.create_role(name: 'Marauder', description: 'Solemnly swears they\'re up to no good')
hogwarts = Clonk::Group.create(name: 'Hogwarts')
hogwarts.create_subgroup(name: 'Students').add_user(user: Clonk::User.find_by(username: 'hpotter'))
marauders = hogwarts.create_subgroup(name: 'Marauders')
marauders.add_user(user: Clonk::User.find_by(username: 'rlupin'))
marauders.map_role(role: marauder_role)