#coding:utf-8
require 'net/http'
require 'open-uri'
require 'uri'

class EasyPhysics
  attr_accessor :data
  
  def initialize(sid, password)
    @params = {}
    @params['stuNumber'] = sid
    @params['password']  = password
    @data = Hash.new
    @data['test'] = Hash.new
  end

  def post_and_get_cookies
    uri = URI.parse('http://clop.hit.edu.cn/stulogin.action')
    response = Net::HTTP.post_form(uri, @params)
    cookies = set_cookies(response)
  end
    
  def set_cookies(response)
    if(response.code == '200' && !response.body.include?('"result":"err"'))
      all_cookies = response.get_fields('set-cookie')
      cookies_array = Array.new
      all_cookies.each { |cookie|
        cookies_array.push(cookie.split('; ')[0]) 
      }

      cookies = cookies_array.join('; ')
    else
      cookies = ''
    end
  end

  def request_page_and_get_html(cookies)
    http = Net::HTTP.new('clop.hit.edu.cn')
    get_book_path = '/listBookingInfos.action' 
    get_book_response = http.get(get_book_path, { 'Cookie' => cookies } )
    s = ''
    s = get_book_response.body
  end

  def match_html(s)
    m = /<td>.*<\/td>/ 
    es = s.scan(m)
    return es
  end

  def get_name(es)
    #get_name
    if !es.empty?
      name = es[1].match('>.+<').to_s
      l = name.size
      name = name.slice!(1, l-2).force_encoding("UTF-8")
    else
      return ''
    end
  end

  def solve_matching_info(es)
    reds = []
    es.each_index do |index|
      if(index % 8 != 0 && index % 8 != 1) 
        td = es[index]
        td = td.match('>.+<').to_s
        l = td.size
        td = td.slice(1, l-2)
        reds << td
      end
    end
    
    arrs = reds.each_slice(6).to_a
  end

  def format_data(arrs)
    test = []
    a = {}
    for arr in arrs
      arr.each_index do |index|
        str = arr[index].force_encoding("UTF-8")
        case index % 6
        when 0
          a['name'] = str
        when 1
          a['add'] =  str
        when 2
          a['seat'] = str
        when 3
          a['week'] = str 
        when 4
          a['date'] = str
        when 5
          a['period'] = str
        end
      end
      test << a
    end
    test
  end
  
  def set_data(name, test)
    @data['name'] = name 
    @data['test'] = test
  end
  
end
