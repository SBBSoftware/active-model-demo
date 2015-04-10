# validator to allow date, date parseable string or mm/yy
class MultiDateTypeValidator < ActiveModel::EachValidator

  # validates date field for Date, date parseable string or mm/yy
  def validate_each(record, attribute, value)
    return unless value
    # is it a date or does it match mm/yy
    return if (value.is_a? Date) || (value =~ /\A\d{2}\/\d{1,2}\z/ && date_shorthand_valid?(value))
    if value =~ /\A\d\/\d{1,2}\z/
      record.errors[attribute] << (options[:message] || 'is not a valid date')
    else
      begin
        Date.parse(value)
      rescue ArgumentError
        record.errors[attribute] << (options[:message] || 'is not a valid date')
      end
    end
  end

  # see if mm/yy generates a valid date
  def date_shorthand_valid?(value)
    date_split = value.split('/')
    month = date_split[0].to_i
    true if month.between?(1, 12)
  end
end
