module ApplicationHelper
def change_to_value(val)
  val.gsub!('"',"")
  val.gsub!('[',"")
  val.gsub!(']',"")
return val
end 

def change_to_value_graph(val)
  val.gsub!('"',"")
  val.gsub!('[',"")
  val.gsub!(']',"")
  val.gsub!(',',"")
  val.gsub!(@localcurrency,"")
  if val.blank?
    val = "0"
  end
return val
end

def url_friendly(val)
  newvar = val.gsub(/[^a-z0-9]+/i, '-')
  newvar = newvar.downcase!
return newvar
end


end
