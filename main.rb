# encoding: utf-8
require 'json'
load 'easy_physics.rb'

sid      = '1120310617'
password = '1120310617'

#format as: 
#       data = { 'name' => 'xxx', 
#                 'test' => [
#                             {name, add, seat, week, date, period},
#                             {name, add, seat, week, date, period},
#                             {name, add, seat, week, date, period},
#                             {name, add, seat, week, date, period}
#                           ]
#               }
#when sid or password is illegal
#       data = '用户名或密码不正确'
#when fetching for the booking is nil
#       data = '尚无预约'

#to-do
#get the score of the user
#store the data into file and expose it to the master


physics = EasyPhysics.new(sid, password)

cookies = physics.post_and_get_cookies
if cookies.empty?
  physics.data = '用户名或密码不正确'
else
  html = physics.request_page_and_get_html(cookies)

  #get the array of match
  es = physics.match_html(html)

  #尚无预约
  if es.empty?
    physics.data = '尚无预约'
  else
    name = physics.get_name(es)

    arrs = physics.solve_matching_info(es)

    #get the all the experiments encapsulated with the form of hash
    test = physics.format_data(arrs)

    physics.set_data(name, test)
  
  end
end
  
f=File.new(File.join("./tmp","#{sid}.txt"), "w+")
f.puts physics.data.to_json

