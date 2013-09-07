require 'net/http'
require 'open-uri'
require 'uri'

params = {}  
params["stuNumber"] = '1120310618'  
params["password"] =  '1120310618'
params["unit"] = '1'

#网址
root_path = 'http://clop.hit.edu.cn'

#登陆
login_path = '/stulogin.action'

#查询成绩
get_mark_path  = "/listScores.action"
get_mark_response = ''
get_mark = 'get_mark.txt'

#查询预约
get_book_path = "/listBookingInfos.action"
get_book_response = ''
get_book = "get_book.txt"

#取消预约
cancel_book_path = "/toCancel.action"
cancel_book_response = '' 
cancel_book  = "cancel_book.txt"

#修改密码
reset_password_path = "/toResetPassWord.action"
reset_password_response = ''
reset_password = "reset_password.txt"

http = Net::HTTP.new('clop.hit.edu.cn')

uri = URI.parse("http://clop.hit.edu.cn/stulogin.action")  

response = Net::HTTP.post_form(uri, params)   
cookies = ''

#make a request to get the server's cookies
if (response.code == '200')
    all_cookies = response.get_fields('set-cookie')
    cookies_array = Array.new
    all_cookies.each { | cookie |
        cookies_array.push(cookie.split('; ')[0])
    }
    cookies = cookies_array.join('; ')
end

# now make a request using the cookies
get_mark_response = http.get(get_mark_path, { 'Cookie' => cookies })
get_book_response = http.get(get_book_path, { 'Cookie' => cookies })
reset_password_response = http.get(reset_password_path, { 'Cookie' => cookies })
cancel_book_response = http.get(cancel_book_path, { 'Cookie' => cookies })

file = File.new(File.join("./", get_mark), "w")
file.puts get_mark_response.body

file = File.new(File.join("./", get_book), "w")
file.puts get_book_response.body

file = File.new(File.join("./", cancel_book), "w")
file.puts cancel_book_response.body


file = File.new(File.join("./", reset_password), "w")
file.puts reset_password_response.body

