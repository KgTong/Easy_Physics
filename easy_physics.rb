#coding:utf-8
require 'net/http'
require 'open-uri'
require 'uri'

class EasyPhysics
  attr_accessor :data
  
  WEEK = %{ 1 2 3 4 5 }
  
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

  def get_name(html)
    if !html.empty?
      name =  html.match('&nbsp;&nbsp;.*&nbsp;&nbsp;').to_s
      name = name.split('&nbsp;')[2].force_encoding("UTF-8")
    else
      return ''
    end
  end

  #return the booking page's html
  def request_page_and_get_book_html(cookies)
    http = Net::HTTP.new('clop.hit.edu.cn')
    get_book_path = '/listBookingInfos.action' 
    get_book_response = http.get(get_book_path, { 'Cookie' => cookies } )
    s = ''
    s = get_book_response.body
  end

  def match_html(html)
    m = /<td>.*<\/td>/ 
    es = html.scan(m)
    return es
  end

  #return a array with the format with [[name, seat, ...], [name, seat, ...], ...]
  def solve_book_matching_info(book_td_labels)
    reds = []
    book_td_labels.each_index do |index|
      if(index % 8 != 0 && index % 8 != 1) 
        td = book_td_labels[index]
        td = td.match('>.+<').to_s
        l = td.size
        td = td.slice(1, l-2).force_encoding("UTF-8")
        if index % 8 == 6
          case td
          when '一'
            td = '1'
          when '二'
            td = '2'
          when '三'
            td = '3'
          when '四'
            td = '4'
          when '五'
            td = '5'
          end 
        end
        reds << td
      end
    end
    
    arrs = reds.each_slice(6).to_a
  end

  #return the booking page's html
  def request_page_and_get_score_html(cookies)
    http = Net::HTTP.new('clop.hit.edu.cn')
    get_score_path = '/listScores.action' 
    get_score_response = http.get(get_score_path, { 'Cookie' => cookies } )
    s = ''
    s = get_score_response.body
  end

  #return a array with the format with [[name, score], [name, score], ...]
  def solve_score_matching_info(book_td_labels)
    submited_report_counts = book_td_labels.shift.split('>')[3].split('<')[0]
    current_mark = book_td_labels.pop.split('>')[3].split('<')[0]
    score_reds = []
    book_td_labels.each_index do |index|
        td = book_td_labels[index]
        td = td.match('>.+<').to_s
        l = td.size
        td = td.slice(1, l-2)
        score_reds << td
    end
    
    score_arrs = score_reds.each_slice(2).to_a
    [submited_report_counts, current_mark, score_arrs]
  end

  def format_data(book_arrs, score_arrs = [])
    test = []
    for book_arr in book_arrs
      a = {}

      book_arr.each_index do |index|
        str = book_arr[index].force_encoding("UTF-8")
        a['score'] = ''
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
  
      unless score_arrs.empty? 
        #now insert the score into the a by comparing the experiment_name
        for score_arr in score_arrs
            if (a['name'].force_encoding("UTF-8") == score_arr[0].force_encoding("UTF-8"))
              a['score'] = score_arr[1]
              break
            else
              a['score'] = ''
            end
        end
      else
        a['score'] = ''
      end
      
      #now a complete record has generated
      test << a
    end
    test
  end

  def set_data(name, test, submited_report_counts, current_mark)
    @data['name'] = name 
    @data['test'] = test
    @data['status'] = 1
    @data['submit'] = submited_report_counts.force_encoding("UTF-8")
    @data['mark']  = current_mark.force_encoding("UTF-8")
  end
end
