json.id widget.uid
json.extract! widget, :name, :multiplier
json.status widget.aasm_state
# json.user widget.user do |user|
#   json.partial! :user, user: user
# end
