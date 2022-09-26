use "backpressure"
use "process"
use "files"
use "json"

actor Main
	var value: I64 = 0
	var env: Env

	fun save() =>
		let path = FilePath(FileAuth(env.root), "./.data.json")
		match File(path)
		| let file: File =>
			let data: JsonObject = JsonObject
			data.data.update("value", value)
			let string''' = data.string("\t", true)
			file.write(string''')
			file.set_length(string'''.size())
			file.flush()
			env.err.print(string''')
			consume file
		end

	fun ref load() =>
		let path = FilePath(FileAuth(env.root), "./.data.json")
		var json_string = ""
		let json_doc = JsonDoc
		match OpenFile(path)
		| let file: File =>
			while file.errno() is FileOK do
				json_string = json_string + file.read_string(1024)
			end
		else
			env.err.print("Unable to load!")
		end
		json_string = json_string
		

		try
			json_doc.parse(json_string)?
		else
			env.err.print(json_string)
		end
		
		try
			var json_object: JsonObject = (
				match json_doc.data
				| let obj: JsonObject =>
					obj
				else
					error
				end
			)
			value = JsonUtil.fetch_data_i64(json_object, "value")?
		end

	fun util_new() => 
		let client = ProcessClient(env)
		let notifier: ProcessNotify iso = consume client
		let path = FilePath(FileAuth(env.root), "/bin/xmessage")
		let args: Array[String] val = [
			"xmessage"
			"value = " + value.string()
			"-buttons"; "improve:0,exit:0"
			"-print"
		]
		let vars: Array[String] val = ["HOME=/"; "PATH=/bin"; "DISPLAY=:0"]
		let sp_auth = StartProcessAuth(env.root)
		let bp_auth = ApplyReleaseBackpressureAuth(env.root)
		let pm: ProcessMonitor = ProcessMonitor(
			sp_auth, bp_auth, consume notifier,
			path, args, vars
		)
		pm.done_writing()

	new create(arg_env: Env) =>
		env = arg_env
		load()
		util_new()
	
	new improve(arg_env: Env) =>
		env = arg_env
		load()
		value = value + 1
		save()
		util_new()

	
		

class ProcessClient is ProcessNotify
	let env: Env

	new iso create(arg_env: Env) =>
		env = arg_env

	fun ref stdout(process: ProcessMonitor ref, data: Array[U8] iso) =>
		let out: String = String.from_array(consume data).substring(0, -1)
		env.err.print(out)
		match out
		| "improve" =>
			let main = Main.improve(env)
		else 
			env.out.print("<*>")
		end

	fun ref stderr(process: ProcessMonitor ref, data: Array[U8] iso) =>
		let err = String.from_array(consume data)
		env.err.print("STDERR: " + err)

	fun ref failed(process: ProcessMonitor ref, err: ProcessError) =>
		env.err.print(err.string())

	fun ref dispose(process: ProcessMonitor ref, child_exit_status: ProcessExitStatus) =>
		match child_exit_status
		| let exited: Exited =>
			env.err.print("Child exit code: " + exited.exit_code().string())
		| let signaled: Signaled =>
			env.err.print("Child terminated by signal: " + signaled.signal().string())
		end
