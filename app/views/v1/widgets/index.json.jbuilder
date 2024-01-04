json.array! @widgets do |widget|
  json.partial! 'widget', widget: widget
end
