module PlainCardsHelper
  # convert a date to a mm/yy format
  def just_date_year(date)
    "#{date.strftime('%m')}/#{date.strftime('%y')}" if date.is_a? Date
  end
end
