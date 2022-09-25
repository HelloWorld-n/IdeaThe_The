use "backpressure"
use "process"
use "files"

actor Main
	var value: I64 = 0

	new create(env: Env) =>
		let client = ProcessClient(env, this)
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

class ProcessClient is ProcessNotify
	let env: Env
	let main: Main

	new iso create(arg_env: Env, arg_main: Main) =>
		env = arg_env
		main = arg_main

	fun ref stdout(process: ProcessMonitor ref, data: Array[U8] iso) =>
		let out = String.from_array(consume data)
		env.err.print(out)
		match out
		| "improve" =>
			env.out.print("Improved!")
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
