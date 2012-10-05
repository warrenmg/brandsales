module ApplicationHelper
def change_to_value(val)
val.gsub!('"',"")
val.gsub!('[',"")
val.gsub!(']',"")
return val
end 
end
