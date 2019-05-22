require "net/http"
require "uri"
require "json"

@time = Time.now
@week_based_year = @time.strftime("%V")
@year = @time.year()

uri = URI.parse("https://oapi.dingtalk.com/robot/send?access_token=1bf51c4eb2722b2099ccdd69b88081bd8c9fe23ab7b148c4877be89e094d864e")
request = Net::HTTP::Post.new(uri)
request.content_type = "application/json"
request.body = JSON.dump({
  "msgtype" => "link",
  "link" => {
    "text" => "经过一周的努力工作，来记录一下这一周里面自己的成长和困惑吧。",
    "title" => "周报提醒",
    "picUrl" => "",
    "messageUrl" => "http://git.2dfire.net/rest-client/weekly/tree/master/#{@year}/#{@week_based_year}/",
  },
})

req_options = {
  use_ssl: uri.scheme == "https",
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

# response.code
# response.body
