use "json"

class JsonUtil

	fun ref fetch_data_simple(json: JsonObject, key: String): (I64|F64|String|Bool)? =>
		try
			match json.data(key)?
			| let value: (I64|F64|String|Bool) =>
				value
			else
				error
			end
		else
			error	
		end

	fun ref fetch_data_stringable(json: JsonObject, key: String): String? =>
		try
			match json.data(key)?
			| let value: Stringable =>
				value.string()
			else
				error
			end
		else
			error	
		end

	fun ref fetch_data_numerical(json: JsonObject, key: String): (I64|F64)? =>
		try
			match json.data(key)?
			| let value: I64 =>
				value
			| let value: F64 =>
				value
			else
				error
			end
		else
			error	
		end

	
	
	fun ref fetch_data_i64(json: JsonObject, key: String): I64? =>
		try
			match json.data(key)?
			| let value: I64 =>
				value
			else
				error
			end
		else
			error	
		end

	fun ref fetch_data_f64(json: JsonObject, key: String): F64? =>
		try
			match json.data(key)?
			| let value: F64 =>
				value
			else
				error
			end
		else
			error	
		end

	fun ref fetch_data_string(json: JsonObject, key: String): String? =>
		try
			match json.data(key)?
			| let value: String =>
				value
			else
				error
			end
		else
			error	
		end

	fun ref fetch_data_bool(json: JsonObject, key: String): Bool? =>
		try
			match json.data(key)?
			| let value: Bool =>
				value
			else
				error
			end
		else
			error	
		end
