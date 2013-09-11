# encoding: utf-8
require 'json'
load 'easy_physics.rb'

sid      = ARGV[0]
password = ARGV[1]

#format as(everything is ok): 
#       data = { 
#                'name'   => 'xxx', 
#                'status' => 1
#                'test'   => [
#                              {name, add, seat, week, date, period, score},
#                              {name, add, seat, week, date, period, score},
#                              {name, add, seat, week, date, period, score},
#                              {name, add, seat, week, date, period, score}
#                            ],
#               }
#Note:
#when sid or password is illegal
#       data = {
#                 'status' => 2
#              }
#when fetching for the booking is nil
#       data = {
#                 'status' => 3
#              }
#when password is reset successfully
#      data = {
#                 'status' => 4
#             }

#to-do
#get the score of the user

physics = EasyPhysics.new(sid, password)

cookies = physics.post_and_get_cookies
if cookies.empty?
  physics.data = {}
  physics.data['status'] = 2
else
  book_html  = physics.request_page_and_get_book_html(cookies)
  score_html = physics.request_page_and_get_score_html(cookies)

  #get the array of match
  book_es   = physics.match_html(book_html)
  score_es  = physics.match_html(score_html)
  
  #尚无预约
  if book_es.empty?
    physics.data = {}
    physics['status'] = 3
  else
    name = physics.get_name(book_html)

    book_arrs   = physics.solve_book_matching_info(book_es)
    score_arrs  = physics.solve_score_matching_info(score_es)
    
    #mock score data
    #score_arrs  = [['惠斯通电桥测电阻', '8'], ['光的等厚干涉现象与应用', '9']]

    #get the all the experiments encapsulated with the form of hash
    test = physics.format_data(book_arrs, score_arrs)

    physics.set_data(name, test)
  end
end
  
f=File.new(File.join("./tmp","#{sid}"), "w+")
f.puts physics.data.to_json
