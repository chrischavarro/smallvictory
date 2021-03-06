class Task < ApplicationRecord
	has_many :task_type_track_associations
	has_many :tracks, through: :task_type_track_associations

	has_many :task_type_associations
	has_many :task_types, through: :task_type_associations

	has_many :user_completions

end
