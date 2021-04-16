extends SplitContainer

func _ready(): connect("dragged", self, "dragged")

func dragged(offset): split_offset = offset
