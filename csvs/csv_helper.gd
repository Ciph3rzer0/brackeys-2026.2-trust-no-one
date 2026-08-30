class_name CSVHelper
const FILE_PATH = "res://csvs/simulation.csv"
const MANUAL_PATH = "res://csvs/manual.csv"

const HEADER_ROW: PackedStringArray = [
	'unix_timestamp',
	'camera_id',
	'vehicle_plate',
	'vehicle_color',
	'vehicle_type',
	'vehicle_features',
	]

static var file_start = true

static func append_to_csv(sighting: SchemaVehicleSightings) -> void:
	if file_start:
		start_new_csv_file()
		file_start = false
	
	var row_data: PackedStringArray = [
		sighting.unix_timestamp,
		sighting.camera_id,
		sighting.vehicle_plate,
		sighting.vehicle_color,
		sighting.vehicle_type,
		sighting.vehicle_features,
	]
	
	# 1. Open the file in READ_WRITE mode so it doesn't erase existing content
	var file = FileAccess.open(FILE_PATH, FileAccess.READ_WRITE)
	
	if file == null:
		print("Failed to open file. Error code: ", FileAccess.get_open_error())
		return
	
	if file:
		# 2. Move the file cursor to the absolute end of the file
		file.seek_end()
		
		# 3. Store the array as a properly formatted CSV line
		file.store_csv_line(row_data)
		
		# 4. Close the file to save changes
		file.close()
	else:
		# If the file doesn't exist, create it cleanly using WRITE mode
		var error = FileAccess.get_open_error()
		if error == ERR_FILE_NOT_FOUND:
			file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
			if file:
				file.store_csv_line(row_data)
				file.close()
			else:
				print("Failed to create file: ", FileAccess.get_open_error())
		else:
			print("Failed to open file: ", error)

static func start_new_csv_file():
	# Open the file for writing (creates or overwrites the file)
	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	
	if file == null:
		print("Failed to open file. Error code: ", FileAccess.get_open_error())
		return
		
	# 1. Write the header row
	# store_csv_line expects a PackedStringArray
	file.store_csv_line(PackedStringArray(HEADER_ROW))
	
	# 3. Close the file to save changes safely
	file.close()
	print("New CSV Created: ", FILE_PATH)

static func load_all_data() -> Array[SchemaVehicleSightings]:
	var array = load_data_from_csv(FILE_PATH)
	array.append_array(load_data_from_csv(MANUAL_PATH))
	
	# Sort by time ADC
	array.sort_custom(func(a: SchemaVehicleSightings, b: SchemaVehicleSightings):
		return a.unix_timestamp < b.unix_timestamp
	)
	
	return array


static func load_all_data_async(
	scene_tree: SceneTree,
	rows_per_frame := 250
) -> Array[SchemaVehicleSightings]:
	var array: Array[SchemaVehicleSightings] = await load_data_from_csv_async(
		FILE_PATH, scene_tree, rows_per_frame
	)
	array.append_array(
		await load_data_from_csv_async(MANUAL_PATH, scene_tree, rows_per_frame)
	)
	array.sort_custom(func(a: SchemaVehicleSightings, b: SchemaVehicleSightings):
		return a.unix_timestamp < b.unix_timestamp
	)
	return array


static func load_data_from_csv_async(
	file_path: String,
	scene_tree: SceneTree,
	rows_per_frame := 250
) -> Array[SchemaVehicleSightings]:
	assert(file_path.get_extension() == "csv")
	assert(file_path.begins_with("res://"))

	var parsed_data: Array[SchemaVehicleSightings] = []
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open %s. Error code: %d" % [file_path, FileAccess.get_open_error()])
		return parsed_data

	var headers := file.get_csv_line()
	var csv_row_number := 1
	var processed_rows := 0
	while not file.eof_reached():
		var row := file.get_csv_line()
		csv_row_number += 1
		if row.size() == 0 or (row.size() == 1 and row[0] == ""):
			continue

		var sighting := _parse_sighting_row(headers, row, file_path, csv_row_number)
		if sighting:
			parsed_data.append(sighting)

		processed_rows += 1
		if processed_rows % maxi(1, rows_per_frame) == 0:
			await scene_tree.process_frame

	file.close()
	return parsed_data

static func load_data_from_csv(file_path: String) -> Array[SchemaVehicleSightings]:
	assert(file_path.get_extension() == 'csv')
	assert(file_path.begins_with('res://'))
	
	var parsed_data: Array[SchemaVehicleSightings] = []
	
	# Open the file for reading
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		print("Failed to open file. Error code: ", FileAccess.get_open_error())
		return parsed_data
		
	# 1. Read the very first line as headers
	var headers = file.get_csv_line()
	var csv_row_number := 1
	
	# 2. Loop through the rest of the file until the end
	while not file.eof_reached():
		var row = file.get_csv_line()
		csv_row_number += 1
		
		# Skip empty rows (like a blank line at the end of the file)
		if row.size() == 0 or (row.size() == 1 and row[0] == ""):
			continue
		var sighting := _parse_sighting_row(headers, row, file_path, csv_row_number)
		if sighting:
			parsed_data.append(sighting)
		
	file.close()
	return parsed_data


static func _parse_sighting_row(
	headers: PackedStringArray,
	row: PackedStringArray,
	file_path: String,
	csv_row_number: int
) -> SchemaVehicleSightings:
	if row.size() != headers.size():
		push_error(
			"Skipping malformed CSV row %d in %s: expected %d columns, found %d."
			% [csv_row_number, file_path, headers.size(), row.size()]
		)
		return null

	var row_dict := {}
	for i in range(headers.size()):
		row_dict[headers[i]] = row[i]

	var sighting := SchemaVehicleSightings.new()
	if row_dict.unix_timestamp.is_valid_int():
		sighting.unix_timestamp = int(row_dict.unix_timestamp)
	else:
		sighting.unix_timestamp = Time.get_unix_time_from_datetime_string(
			row_dict.unix_timestamp
		)
	sighting.camera_id = row_dict.camera_id
	sighting.vehicle_plate = row_dict.vehicle_plate
	sighting.vehicle_color = row_dict.vehicle_color
	sighting.vehicle_type = row_dict.vehicle_type
	sighting.vehicle_features = [] as Array[String]

	var features_json := JSON.new()
	var features_error := features_json.parse(row_dict.vehicle_features)
	if features_error != OK or not features_json.data is Array:
		push_error(
			"Skipping malformed vehicle features at row %d in %s: %s"
			% [csv_row_number, file_path, features_json.get_error_message()]
		)
		return null

	for item in features_json.data:
		sighting.vehicle_features.append(str(item))
	return sighting
