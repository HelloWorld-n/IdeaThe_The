use "backpressure"
use "process"
use "files"

actor Main
	new create(env: Env) =>
		let client = ProcessClient(env)
		let notifier: ProcessNotify iso = consume client
		let path = FilePath(FileAuth(env.root), "/bin/xmessage")
		let args: Array[String] val = [
			"xmessage"
			"Pick()?"
			"-buttons"; "zero\\:0:0,one\\:1:0,two\\:2:0,three\\:3:0"
			"-print"
		]
		let vars: Array[String] val = ["HOME=/"; "PATH=/bin"; "DISPLAY=:0"]
		let sp_auth = StartProcessAuth(env.root)
		let bp_auth = ApplyReleaseBackpressureAuth(env.root)
		let pm: ProcessMonitor = ProcessMonitor(
			sp_auth, bp_auth, consume notifier,
			path, args, vars
		)
		// write to STDIN of the child process
		pm.done_writing() // closing stdin allows cat to terminate

// define a client that implements the ProcessNotify interface
class ProcessClient is ProcessNotify
	let _env: Env

	new iso create(env: Env) =>
		_env = env

	fun ref stdout(process: ProcessMonitor ref, data: Array[U8] iso) =>
		let out = String.from_array(consume data)
		_env.out.print("STDOUT: " + out)

	fun ref stderr(process: ProcessMonitor ref, data: Array[U8] iso) =>
		let err = String.from_array(consume data)
		_env.out.print("STDERR: " + err)

	fun ref failed(process: ProcessMonitor ref, err: ProcessError) =>
		_env.out.print(err.string())

	fun ref dispose(process: ProcessMonitor ref, child_exit_status: ProcessExitStatus) =>
		match child_exit_status
		| let exited: Exited =>
			_env.out.print("Child exit code: " + exited.exit_code().string())
		| let signaled: Signaled =>
			_env.out.print("Child terminated by signal: " + signaled.signal().string())
		end
