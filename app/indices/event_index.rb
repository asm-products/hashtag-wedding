ThinkingSphinx::Index.define :event, :with => :active_record do
  indexes :tag

  has :id
end