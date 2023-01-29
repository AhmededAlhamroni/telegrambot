require 'telegram/bot'
require 'active_support/core_ext/numeric/time'

TOKEN = '5627100893:AAFory-BGKyGHEtMZAnv03rhKZuaeS-bhyk'
OWNER_CHAT_ID = 1261874945

message = ""
receivers = []
interval = 2.hours

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    if message.chat.id == OWNER_CHAT_ID
      case message.text
      when '/message'
        if message.text.split(" ").length > 1
          message = message.text.split(" ")[1..-1].join(" ")
          bot.api.send_message(chat_id: message.chat.id, text: "The message successfully updated.")
        else
          bot.api.send_message(chat_id: message.chat.id, text: "Invalid command format. Please use the format /message [message].")
        end
      when '/receivers'
        if message.text.split(" ").length > 1
          receivers = message.text.split(" ")[1..-1]
          if receivers.include?("all")
            receivers = []
            bot.api.send_message(chat_id: message.chat.id, text: "The message will be sent to all subscribers of the bot.")
          else
            bot.api.send_message(chat_id: message.chat.id, text: "The message will be sent to: #{receivers.join(', ')}.")
          end
        else
          bot.api.send_message(chat_id: message.chat.id, text: "Invalid command format. Please use the format /receivers [usernames].")
        end
      when '/interval'
        if message.text.split(" ").length > 1
          interval = message.text.split(" ")[1].to_i.hours
          bot.api.send_message(chat_id: message.chat.id, text: "The interval has been set to #{interval/1.hour} hours.")
        else
          bot.api.send_message(chat_id: message.chat.id, text: "Invalid command format. Please use the format /interval [hours].")
        end
      end
    else
      bot.api.send_message(chat_id: message.chat.id, text: "You are not authorized to use this bot.")
    end
  end

  loop do
    if message != ""
      if receivers.empty?
        bot.api.get_chat_members_count.each { |m| bot.api.send_message(chat_id: m.id, text: message) }
      else
        receivers.each { |r| bot.api.send_message(chat_id: r, text: message) }
      end
    end
    sleep(interval)
  end
end
