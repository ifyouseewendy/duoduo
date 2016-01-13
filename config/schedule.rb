# Learn more: http://github.com/javan/whenever

set :output, "log/schedule.log"

every :day, :at => '01:00am' do
  rake "pg:dump"
end
