$:.unshift File.dirname(__FILE__)
# encoding: utf-8
require 'json'
require 'easy_physics'
require 'easy_physics_ext'

sid      = ARGV[0]
old_password = ARGV[1]
new_password = ARGV[2]


physics = EasyPhysics.new(sid, old_password)

cookies = physics.post_and_get_cookies
if cookies.empty?
  physics.data = {}
  physics.data['status'] = 2
else
  physics.resetPassword(cookies, new_password)
end
  
f=File.new(File.join("#{File.dirname(__FILE__)}/tmp","#{sid}"), "w+")
f.puts physics.data.to_json
