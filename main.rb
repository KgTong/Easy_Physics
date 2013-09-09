# encoding: utf-8
load 'easy_physics.rb'

sid = '1120310618'
password = '1120310618'

#format as: 
#data = { 'name' => 'xxx', 
#         'test' => [
#                    {name, add, seat, week, date, period},
#                    {name, add, seat, week, date, period},
#                    {name, add, seat, week, date, period},
#                    {name, add, seat, week, date, period}
#                  ]
#        }

#to-do
#get the score of the user
#store the data into file and expose it to the master


physics = EasyPhysics.new(sid, password)

cookies = physics.post_and_get_cookies

html = physics.request_page_and_get_html(cookies)

#get the array of match
es = physics.match_html(html)

name = physics.get_name(es)

arrs = physics.solve_matching_info(es)

#get the all the experiments encapsulated with the form of hash
test = physics.format_data(arrs)

physics.set_data(name, test)

puts physics.data
