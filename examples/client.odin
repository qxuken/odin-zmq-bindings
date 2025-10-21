package main

import zmq "../zeromq"
import "core:fmt"
import "core:os"
import "core:slice"

ADDR :: "tcp://127.0.0.1:53534"

main :: proc() {
	ctx := zmq.ctx_new()
	defer zmq.ctx_term(ctx)

	subscriber := zmq.socket(ctx, .SUB)
	defer zmq.close(subscriber)

	if rc := zmq.connect(subscriber, ADDR); rc != 0 {
		zmq.print_zmq_error()
		os.exit(1)
	}

	filter := slice.get(os.args, 1) or_else "10001 "

	if !zmq.setsockopt_string(subscriber, .SUBSCRIBE, filter) {
		zmq.print_zmq_error()
		os.exit(1)
	}
	fmt.println("Subscribing to", filter)

	for _ in 0 ..= 15 {
		str := zmq.recv_string(subscriber, allocator = context.temp_allocator)
		fmt.println("message:", str)
	}
}
