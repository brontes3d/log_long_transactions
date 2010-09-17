ActiveRecord::ConnectionAdapters::MysqlAdapter.class_eval do
  
  def transaction_with_long_transaction_logging(*args, &block)
    start_time = Time.now
    begin
      return transaction_without_long_transaction_logging(*args, &block)
    ensure
      running_time = Time.now - start_time
      RAILS_DEFAULT_LOGGER.debug{ "transaction time #{running_time}" }
      if running_time > 49.seconds
        begin
          raise "tracemeplease"
        rescue => e
          RAILS_DEFAULT_LOGGER.error("transaction "+
                    "transaction_time=#{running_time} trace:\n" + 
                    e.backtrace.join("\n"))
        end
      end
    end
  end
  
  alias_method_chain :transaction, :long_transaction_logging
end

ActiveRecord::Base.class_eval do
  
  def create_or_update_with_long_transaction_logging
    start_time = Time.now
    begin
      return create_or_update_without_long_transaction_logging
    ensure
      running_time = Time.now - start_time
      RAILS_DEFAULT_LOGGER.debug{ "create_or_update time #{running_time}" }
      if running_time > 49.seconds
        begin
          raise "tracemeplease"
        rescue => e
          RAILS_DEFAULT_LOGGER.error("create_or_update #{self.class} #{self.id}" +
                    " transaction_time=#{running_time} trace:\n" + 
                    e.backtrace.join("\n"))
        end
      end
    end
  end
  
  alias_method_chain :create_or_update, :long_transaction_logging
end
