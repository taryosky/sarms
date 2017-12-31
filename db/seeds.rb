# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
	Util.create(name: "site_visits", value: 0)
	Util.create(name: "session", value: "0000/0000")
	Util.create(name: "registration", value: 0)
	Admin.create(id: 1, name:"samuel")
	LoginDetail.create(user_name: "samuel", user_id: 1, user_type: 2, activation: 1, password: "samuel")
