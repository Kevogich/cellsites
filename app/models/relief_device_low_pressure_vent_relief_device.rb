class ReliefDeviceLowPressureVentReliefDevice < ActiveRecord::Base
  belongs_to :relief_device_sizing

  is_pipeable
end
