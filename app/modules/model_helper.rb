module ModelHelper
  def attribute_slice(attr, length)
    self[attr] = (self[attr].mb_chars[0...length]).to_s if !self[attr].nil? && self[attr].mb_chars.length > length
  end
  
  def city_text
    return nil if self.city == 0
    province_id = ProvinceCity::REVERSE_TOP_LIST[self.city]
    if (province_id != self.city)
      "#{ProvinceCity::LIST[province_id]} #{ProvinceCity::LIST[self.city]}"
    else
      ProvinceCity::LIST[self.city]
    end
  end
  
end
