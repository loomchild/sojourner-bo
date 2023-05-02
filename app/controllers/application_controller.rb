class ApplicationController < ActionController::Base
  # Overriding default Turbo::Frames::FrameRequest. Frame layout is provided conditionally in each layout.
  layout nil
  helper_method :turbo_frame_request?
end
