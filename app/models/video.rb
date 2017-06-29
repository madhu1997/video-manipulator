class Video
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

  embeds_many :processing_metadatas

  field :title, type: String
  field :file_tmp, type: String
  field :file_processing, type: Boolean
  field :file_duration, type: Integer
  field :progress, type: Float, default: 0

  field :effects, type: Array, default: []

  mount_uploader :file, ::VideoUploader
  process_in_background :file
  store_in_background :file
  validates_presence_of :file

  mount_uploader :watermark_image, ::ImageUploader

  validates :title, presence: true
  validate :effects_allowed_check

  # This is not good idea to let this thing update database field many times
  # It is made just to test how it works
  def processing_progress(format, format_options, new_progress)
    ProgressCalculator.new(self, format, format_options, new_progress).update!
  end

  private

  def effects_allowed_check
    self.effects.each do |effect|
      unless ::VideoUploader::ALLOWED_EFFECTS.include?(effect)
        self.errors.add(:effects, :not_allowed, effect: effect.humanize)
      end
    end
  end

end
