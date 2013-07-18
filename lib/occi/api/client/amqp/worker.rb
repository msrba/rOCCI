require "amqp"

module Occi
  module Amqp
    class Worker

      def initialize
        AMQP::Utilities::EventLoopHelper
      end

      def start(options = {})
        defaults = {}

        merge_options options, defaults

        connection = AMQP.connect Config.instance.amqp[:connection_setting]

        channel = AMQP::Channel.new(connection)
        channel.on_error(&method(:handle_channel_exception))

        @queue = channel.queue(options[:queue_name], :exclusive => true, :auto_delete => true)
        @queue.subscribe(&options[:callback])

        @exchange = channel.default_exchange
      end

      def handle_channel_exception(channel, channel_close)
        Occi::Log.error "OCCI/AMQP: Channel-level exception [ code = #{channel_close.reply_code}, message = #{channel_close.reply_text} ]"
      end

      def next_message_id
        @message_id  = 0 if @message_id.nil?
        @message_id += 1
        @message_id.to_s;
      end

      def waiting_for_response(message_id = '')
        return if @response_waiting.nil?

        if message_id.size > 0
          sleep(0.1) while !@response_waiting[message_id].nil?
        else
          sleep(0.1) while size(@response_waiting) > 0
        end
      end

      def request(message, options = {})
        defaults = {
          :wait => false
        }

        merge_options options, defaults

        message_id = message.options["message_id"]

        @exchange.publish(message.payload, message.options)

        @response_waiting             = Hash.new if @response_waiting.nil?
        @response_waiting[message_id] = {:message => message}

        waiting_for_response(message_id) if wait

        message_id
      end

      def set_response_message(metadata, payload)
        correlation_id = metadata.correlation_id

        unless correlation_id.size > 0
          raise "Message has no correlation_id (message_id)"
        end

        @response_messages = Hash.new                             if @response_messages.nil?
        raise "Double Response Message ID: (#{ correlation_id })" if @response_messages.has_key?(correlation_id)
        message = @response_waiting[correlation_id][:message]
        #save responses message
        @response_messages[correlation_id] = {:payload => payload, :metadata => metadata, :type => message.options[:type]}

        #delete message_id from waiting stack
        @response_waiting.delete(correlation_id) unless @response_waiting.nil?
      end

      def pop_response_message(message_id)
        @response_messages[message_id].delete
      end

      def join
        t = AMQP::Utilities::EventLoopHelper.eventmachine_thread
        t.join unless t.nil?
      end

      private
      def merge_options(opt1, opt2)
        opt1 = opt1.marshal_dump if opt1.is_a? OpenStruct
        opt2.merge opt1
      end

    end
  end
end