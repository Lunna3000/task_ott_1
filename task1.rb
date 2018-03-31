require 'time'

logFile=File.new('nginx.rtf')

bigStatus = []
xRespTime = []
errorAmt = []
allUpStatus = []

string = logFile.gets

while string != nil
  puts string

  dateString = string[/\[.*\/.*\/.*:.*:.*:.* +.*\]/]
  if dateString
    date = dateString.sub(':', ' ')
    timeLog = Time.parse(date)
    today = Time.new
    dayBefore = today - 86400
    time_Day = dayBefore..today
  end

  if string.include?('up_status')
    upStatus = string[/up_status=".*"/][11..13].to_i
    allUpStatus.push(upStatus)

    if upStatus > 200 && time_Day.include?(timeLog)
      bigStatus.push(upStatus)

    elsif upStatus == 200
      statusX = string[/x_resp_time=".*"/][13..18].to_f
      xRespTime.push(statusX)

    else upStatus < 200
    end
  end

  string = logFile.gets
end


if bigStatus.length != 0

  cell = 0
  while cell < bigStatus.length
    error = bigStatus[cell]

    amt = 0
    bigStatus.each do |unique|
      if unique == error
        amt += 1
      end
    end

    answer = error, '-', amt
    errorAmt.push(answer)

    cell = cell += 1
  end

  print "\n ", bigStatus.length, ' out ', allUpStatus.length, ' requests returned non 200 code', "\n"
  puts "\n", errorAmt.uniq

else
  print "\n", 'No replies with up_status>200', "\n"
end

sum = 0
xRespTime.each do |ms|
  sum += ms
end
mean = sum / xRespTime.length

print "\n", 'Average response with 200 code: ',  mean.round(2), 'ms'

logFile.close